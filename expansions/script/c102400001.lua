--created & coded by Lyris, art from Yu-Gi-Oh! Duel Monsters Episode 86
--早すぎた決断
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function cid.filter2(c,g,tp)
	return g:IsExists(cid.filter1,1,c,tp,c)
end
function cid.filter1(c,tp,tc)
	return Duel.IsExistingMatchingCard(cid.filter3,tp,LOCATION_DECK,0,1,Group.FromCards(c,tc),tc:GetCode(),c:GetCode())
end
function cid.filter3(c,code1,code2)
	return c:IsCode(code1) and c:IsCode(code2) and c:IsAbleToHand()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:IsExists(cid.filter2,1,nil,g,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:FilterSelect(tp,cid.filter2,1,1,nil,g,tp)
	local tc=tg:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=g:FilterSelect(tp,cid.filter1,1,1,tg,tp,tc):GetFirst()
	tg:AddCard(sc)
	if #tg~=2 or Duel.SendtoGrave(tg,REASON_COST)==0 or tg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectMatchingCard(tp,cid.filter3,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode(),sc:GetCode())
	if #sg>0 then
		Duel.BreakEffect()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_HAND) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(cid.aclimit)
			e1:SetLabel(sg:GetFirst():GetCode())
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function cid.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and not re:GetHandler():IsImmuneToEffect(e)
end
