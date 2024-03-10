--created by Seth, coded by Lyris
--Mextro Factory
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT()
	e2:SetDescription(1192)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:HOPT()
	e3:SetDescription(1152)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.cfilter(c,tp)
	return c:IsSetCard(0xee5) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
function s.filter(c,lv)
	return c:IsSetCard(0xee5) and c:IsType(TYPE_MONSTER) and not c:IsLevel(lv) and c:IsAbleToHand()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetLevel())
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
function s.lfilter(c)
	return c:IsSetCard(0xee5) and c:IsType(TYPE_LINK)
end
function s.gchk(g,e,tp)
	if g:IsExists(aux.NOT(Card.IsAbleToExtraAsCost),1,nil) then return false end
	local t={g:GetSum(Card.GetLink)}
	for tc in aux.Next(g) do table.insert(t,tc:GetLink()) end
	return Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK,0,nil,e,tp):CheckSubGroup(s.schk,1,#g,0,table.unpack(t))
end
function s.sfilter(c,e,tp)
	return c:IsSetCard(0xee5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.schk(g,chk,tlk,...)
	local t={...}
	if Duel.GetLocationCount(tp,LOCATION_MZONE)+#t*(1-chk)<#g then return false end
	local tlv=g:GetSum(Card.GetLevel)
	if tlv==tlk then return true end
	for _,l in ipairs(t) do if tlv==l then return true end end
	return false
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.lfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then return #g>1 and g:CheckSubGroup(s.gchk,1,3) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=g:SelectSubGroup(tp,s.gchk,false,1,3,e,tp)
	local t={#tg,1,tg:GetSum(Card.GetLink)}
	for tc in aux.Next(tg) do table.insert(t,tc:GetLink()) end
	Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_COST)
	e:SetLabel(table.unpack(t))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK,0,nil,e,tp):SelectSubGroup(tp,s.schk,false,1,e:GetLabel())
	if g then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
