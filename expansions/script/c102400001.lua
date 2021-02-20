--created & coded by Lyris, art from Yu-Gi-Oh! Duel Monsters Episode 86
--早すぎた決断
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.filter2(c,g,tp)
	return g:IsExists(s.filter1,1,c,tp,c)
end
function s.filter1(c,tp,tc)
	return Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_DECK,0,1,Group.FromCards(c,tc),tc:GetCode(),c:GetCode())
end
function s.filter3(c,code1,code2)
	return c:IsCode(code1) and c:IsCode(code2) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:IsExists(s.filter2,1,nil,g,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:FilterSelect(tp,s.filter2,1,1,nil,g,tp)
	local tc=tg:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=g:FilterSelect(tp,s.filter1,1,1,tg,tp,tc):GetFirst()
	tg:AddCard(sc)
	if #tg~=2 or Duel.SendtoGrave(tg,REASON_COST)==0 or tg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode(),sc:GetCode())
	if #sg>0 then
		Duel.BreakEffect()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		local uc=sg:GetFirst()
		if uc:IsLocation(LOCATION_HAND) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.aclimit(tc:GetCode(),sc:GetCode(),uc:GetCode()))
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.aclimit(...)
	local codes={...}
	return  function(e,re,tp)
				return re:GetHandler():IsCode(table.unpack(codes)) and not re:GetHandler():IsImmuneToEffect(e)
			end
end
