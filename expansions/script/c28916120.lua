--Execouncil Blackblade
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,ref=getID()
function ref.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADDITIONAL_MAGICK_LOCATION)
	e0:SetRange(LOCATION_GRAVE)
	c:RegisterEffect(e0)
	--ATK up
	local magick=Effect.CreateEffect(c)
	magick:SetDescription(aux.Stringid(id,0))
	magick:SetCategory(CATEGORY_ATKCHANGE)
	magick:SetType(EFFECT_TYPE_TRIGGER_O)
	magick:SetProperty(EFFECT_FLAG_DELAY)
	magick:SetCondition(ref.atkcon)
	magick:SetTarget(ref.atktg)
	magick:SetOperation(ref.atkop)
	--Duoate
	local magick2=Effect.CreateEffect(c)
	magick2:SetDescription(aux.Stringid(id,0))
	magick2:SetCategory(CATEGORY_TOGRAVE)
	magick2:SetType(EFFECT_TYPE_TRIGGER_O)
	magick2:SetProperty(EFFECT_FLAG_DELAY)
	magick2:SetCondition(ref.tgcon)
	magick2:SetTarget(ref.tgtg)
	magick2:SetOperation(ref.tgop)
	aux.AddMagickProcCustom(c,ref.magcon,aux.MagickMatCost,magick,aux.TRUE,1,99)
end
function ref.magcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsCode(CARD_MAGICK_TOKEN)
end
--ATK up
function ref.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetMaterial():GetClassCount(Card.GetRace)==c:GetMaterialCount()
end
function ref.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,500)
end
function ref.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end

function ref.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMaterialCount()>=3
end
function ref.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #mg>1 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,mg,math.floor(#mg/2),1-tp,LOCATION_ONFIELD)
end
function ref.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_ONFIELD,0,nil)
	local ct=math.floor(#g/2)
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,ct,ct,nil)
		Duel.HintSelection(sg)
		Duel.SendtoGrave(sg,REASON_RULE)
	end
end
