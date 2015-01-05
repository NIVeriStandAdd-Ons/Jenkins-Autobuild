repos   = WScript.Arguments.Item(0)
rev     = WScript.Arguments.Item(1)
svnlook = WScript.Arguments.Item(2)
jenkins = WScript.Arguments.Item(3)

Set shell = WScript.CreateObject("WScript.Shell")

Set uuidExec = shell.Exec(svnlook & " uuid " & repos)
Do Until uuidExec.StdOut.AtEndOfStream
  uuid = uuidExec.StdOut.ReadLine()
Loop
Wscript.Echo "uuid=" & uuid

Set changedExec = shell.Exec(svnlook & " changed --revision " & rev & " " & repos)
Do Until changedExec.StdOut.AtEndOfStream
  changed = changed + changedExec.StdOut.ReadLine() + Chr(10)
Loop
Wscript.Echo "changed=" & changed

url = jenkins + "crumbIssuer/api/xml?xpath=concat(//crumbRequestField,"":"",//crumb)"
Set http = CreateObject("Microsoft.XMLHTTP")
http.open "GET", url, False
http.setRequestHeader "Content-Type", "text/plain;charset=UTF-8"
http.send

crumb = null
if http.status = 200 then
  crumb = split(http.responseText,":")
end if

url = jenkins + "subversion/" + uuid + "/notifyCommit?rev=" + rev
Wscript.Echo url

Set http = CreateObject("Microsoft.XMLHTTP")
http.open "POST", url, False
http.setRequestHeader "Content-Type", "text/plain;charset=UTF-8"
	
if not isnull(crumb) then 
  http.setRequestHeader crumb(0),crumb(1)
  http.send changed
  Wscript.Echo "httpstatus2=" & http.status
  if http.status <> 200 then
    Wscript.Echo "Error. HTTP Status: " & http.status & ". Body: " & http.responseText
  end if
end if