print("Hard wipe starting...")
print("Deleting all files except ROM...")

for _, f in ipairs(fs.list("/")) do
    if f ~= "rom" then
        print("Deleting: " .. f)
        fs.delete(f)
    end
end

print("Wipe complete. Rebooting...")
sleep(1)
os.reboot()
