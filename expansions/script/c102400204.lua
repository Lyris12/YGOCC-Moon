--created & coded by Lyris
--ローマ・キー・VI
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(s.lvup)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e5:SetTarget(s.target)
	e5:SetOperation(s.costop)
	c:RegisterEffect(e5)
	local e4=e5:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e6=e5:Clone()
	e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e6)
end
function s.lvup(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(e:GetHandler():GetLevel()*2)
	e:GetHandler():RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xeeb)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return #Duel.GetMatchingGroup(aux.AND(s.filter,Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,nil)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(Duel.SelectMatchingCard(tp,aux.AND(s.filter,Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,1,5,nil),nil,2,REASON_EFFECT)
	local tg=Duel.GetOperatedGroup()
	if tg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0 then Duel.ShuffleDeck(tp) end
	if #tg>=3 then Duel.Draw(tp,1,REASON_EFFECT) end
	local sg=Duel.GetMatchingGroup(aux.AND(s.filter,Card.IsAbleToHand),tp,LOCATION_DECK,0,nil)
	if #tg>=5 and #sg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=sg:Select(tp,1,1,nil)
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,hg)
	end
end
