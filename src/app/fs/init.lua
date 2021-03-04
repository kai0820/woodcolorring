local fs = {}

fs.Image = require "app.fs.image"
fs.Button = require "app.fs.button"
fs.Label = require "app.fs.label"
fs.Text = require "app.fs.text"
fs.Widget = require "app.fs.widget"
fs.ScrollView = require "app.fs.scrollView"
fs.TableView = require "app.fs.tableView"
fs.RichText = require "app.fs.richText"
fs.RichElementEmpty = require "app.fs.richElementEmpty"
fs.RichElementImage = require "app.fs.richElementImage"
fs.RichElementText = require "app.fs.richElementText"
fs.RichElementNewLine = require "app.fs.richElementNewLine"
fs.SwallowTouchesNode = require "app.fs.swallowTouchesNode"

-- fs.EditBox = require "app.fs.editBox"
-- fs.CheckBox = require "app.fs.checkBox"
-- fs.Slider = require "app.fs.slider"
-- fs.ListView = require "app.fs.listView"
-- fs.PageView = require "app.fs.pageView"
-- fs.LoadingBar = require "app.fs.loadingBar"
-- fs.Text = require "app.fs.text"
-- fs.Particle = require "app.fs.particle"
-- fs.Scale9Sprite = require "app.fs.scale9Sprite"
-- fs.ProgressBar = require "app.fs.progressBar"

return fs