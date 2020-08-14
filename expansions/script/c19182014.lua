--created by Alastar Rainford, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cid.condition)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xa88) and c:GetEquipTarget()~=nil
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_SZONE,0,2,nil)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_SZONE,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
		if sg:GetFirst():IsLocation(LOCATION_GRAVE) then
			local opt=0
			if Duel.IsPlayerCanDraw(tp,2) then opt=Duel.SelectOption(tp,aux.Stringid(id,0),1108)
			else opt=Duel.SelectOption(tp,aux.Stringid(id,0)) end
			if opt==0 then
				Duel.SortDecktop(tp,tp,3)
			else
				Duel.Draw(tp,2,REASON_EFFECT)
			end
		end
	end
end
