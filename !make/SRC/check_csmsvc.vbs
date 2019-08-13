' Адрес сервиса CsmSvc
const csmsvc_host = "127.0.0.1:8091"
' Таймаут ожидания страницы Status, сек
const timeout_seconds = 20
' Таймаут ответа сервера репликации, сек
const replication_timeout = 800

dim xmlhttp, check_result, wshShell

set xmlhttp = CreateObject("MSXML2.XMLHTTP")
set wshShell = CreateObject("WScript.Shell")
set fso = createobject("Scripting.FileSystemObject")

check_result = false
					
On Error Resume Next
		
	xmlhttp.open "get", "http://" & csmsvc_host & "/Status", true
	xmlhttp.setRequestHeader "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT"
	xmlhttp.send
	
	itimetaken = 0
		
	Do Until itimetaken > timeout_seconds
		WScript.Sleep 10
		itimetaken = itimetaken + 10/1000
		If xmlhttp.ReadyState = 4 Then
			Exit Do
		End If
	Loop
	
	records_counters_filename = fso.GetSpecialFolder(2) & "\csmsvc_records_counters.lst"
	
	check_result = false
	
	if xmlhttp.ReadyState = 4 then
		if xmlhttp.status = 200 then
			check_result = true
			is_recording_enabled = false
			
			if xmlhttp.responseText <> "Replication is not enabled" then
			
				StatusArray = ParseStatusResponse(xmlhttp.responseText)
				
				' read file - records counter
				records_saved_data = vbNullString
				
				if fso.FileExists(records_counters_filename) then
				
					set File = fso.GetFile(records_counters_filename)
					set TextStream = File.OpenAsTextStream(1)
					while Not TextStream.AtEndOfStream
						records_saved_data = records_saved_data & TextStream.ReadLine() & vbCrLf
					wend
					set File = Nothing
					set TextStream = Nothing
					
					ar_saved_records = split(records_saved_data,vbCrLf)
					
					if UBound(ar_saved_records) = UBound(StatusArray) then
						for i=0 To UBound(StatusArray)-1
							if CInt(StatusArray(i)(3)) < 10*365*24*3600 then
								if CInt(StatusArray(i)(3)) > CInt(ar_saved_records(i)) then
									if CInt(StatusArray(i)(2)) > replication_timeout then
										is_recording_enabled = true
									end if	
								end if
							end if 
						next					
					end if
					
				end if
							
				Set log_records_stream = fso.CreateTextFile(records_counters_filename)
				for i=0 To UBound(StatusArray)-1
					log_records_stream.WriteLine(StatusArray(i)(3))				
				next
				log_records_stream.Close
				set log_records_stream = Nothing
				
				for i=0 To UBound(StatusArray)-1
					
					' Check COM Connection
					if StatusArray(i)(1) <> "OK" then
						check_result = false
						exit for					
					end if
					
					if CInt(StatusArray(i)(2)) > replication_timeout then
						if Not is_recording_enabled then
							check_result = false
							exit for
						end if
					end if
					
				next			
			end if			
		end if
	end if
			   
On Error Goto 0

if check_result = false then
		
	wshShell.Run "net stop CsmService",0,True 
	WScript.Sleep 5000
	wshShell.Run "taskkill /f /im CsmSvc.exe",0,True 
	WScript.Sleep 5000
	wshShell.Run "net start CsmService",0,True	
	
	WriteToLog "CsmSvc service restart"
	
end if

set xmlhttp = Nothing
set wshShell = Nothing
set fso = Nothing

function ParseStatusResponse(ResponseText)
	
	Dim ar_response()
	
	Set objRegExp = CreateObject("VBScript.RegExp")
	objRegExp.Pattern = "<td[^>]+>([^<]+)</td>[^<]+<td[^>]+>(.+)</td>[^<]+<td[^>]+>(.+)</td>[^<]+<td[^>]+>(.+)</td>[^<]+<td[^>]+>(.+)</td>[^<]+<td[^>]+>(.+)</td>"
	objRegExp.Global = True
	Set objMatches = objRegExp.Execute(ResponseText)
	For i=0 To objMatches.Count-1
		Set objMatch = objMatches.Item(i)
		
		ReDim Preserve ar_response(i+1)
		
		' Thread name, ComConnector status, Replication seconds ago, Records counter
		ar_response(i) = Array(objMatch.Submatches.Item(1),objMatch.Submatches.Item(2),objMatch.Submatches.Item(4),objMatch.Submatches.Item(5))				
				
	Next

	ParseStatusResponse = ar_response	
	
end function

Sub WriteToLog( Message )
	Dim LogPath, text
	
	LogPath = fso.GetSpecialFolder(2) & "\" & Left(WScript.ScriptName, Len(WScript.ScriptName)-3) & "log" 
	Set text = fso.OpenTextFile(LogPath, 8, True)
	text.write Now() & " " & Message & vbcrlf
	text.close
	
End Sub ' WriteToLog()
