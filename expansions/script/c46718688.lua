--Anemone Inquinante
--Scripted by: XGlitchy30

local s,id=GetID()

s.effect_text = [[
● You can only use each effect of "Pollutant Anemone" once per turn.
① When this card is Normal or Special Summoned: You can activate 1 Field Spell from either player's GY to your field, and if you do, replace its effects with the following ones.
● The first time this card would be destroyed by an opponent's card effect, it is not destroyed.
● All monsters on the field, except "Pollutant Anemone", lose 1300 ATK/DEF
● "Pollutant Anemone" gains 1300 ATK/DEF.

② If this card leaves the field: Destroy 1 Field Spell on your field, and if you do, all monsters your opponent currently controls lose 1300 ATK/DEF.
]]

function s.initial_effect(c)
    --Activate Field Spell
	local e1,e1x=c:SummonedTrigger(false,true,true,false,0,nil,true,{1,0},false,false,aux.ActivateFieldSpellTarget(s.filter,LOCATION_GRAVE,LOCATION_GRAVE),s.op)
	e1:SetCustomCategory(CATEGORY_ACTIVATE)
	e1x:SetCustomCategory(CATEGORY_ACTIVATE)
	--Destroy
	local e2=c:LeaveTrigger(true,1,CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE,false,{1,1},false,false,s.target,s.opera)
end
function s.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_FIELD)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g,check=aux.ActivateFieldSpellOperation(s.filter,LOCATION_GRAVE,LOCATION_GRAVE)(e,tp,eg,ep,ev,re,r,rp)
	if check and g:GetFirst():IsLocation(LOCATION_FZONE) and g:GetFirst():IsFaceup() then
		g:GetFirst():ReplaceEffect(id+1,RESET_EVENT+RESETS_STANDARD)
	end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.Group(Card.IsFaceup,tp,0,LOCATION_MZONE)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,-1300)
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,-1300)
end
function s.opera(e,tp,eg,ep,ev,re,r,rp)
	local g,ct=aux.DestroyOperation(aux.Faceup(s.filter),LOCATION_FZONE)(e,tp,eg,ep,ev,re,r,rp)
	if ct>0 then
		local sg=Duel.Group(Card.IsFaceup,tp,0,LOCATION_MZONE)
		for tc in aux.Next(sg) do
			tc:UpdateATK(-1300,true,e:GetHandler())
			tc:UpdateDEF(-1300,true,e:GetHandler())
		end
	end
end