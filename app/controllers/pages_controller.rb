class PagesController < ApplicationController
def index
@ptags= Placetags.all

end
end
