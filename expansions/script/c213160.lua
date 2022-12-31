--Monolith A.W. Ancient Ruins
function c213160.initial_effect(c)
	c:EnableCounterPermit(0x100e)
	c:EnableCounterPermit(0xf)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c213160.acounter)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--counter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(c213160.wcounter)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--to hand
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(213160,0))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTarget(c213160.athtg)
	e6:SetOperation(c213160.athop)
	c:RegisterEffect(e6)
	--to hand
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(213160,1))
	e7:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTarget(c213160.wthtg)
	e7:SetOperation(c213160.wthop)
	c:RegisterEffect(e7)
end
c213160.counter_add_list={0x100e}
function c213160.afilter(c)
	return c:IsSetCard(0xc)
end
function c213160.acounter(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c213160.afilter,1,nil) then
		e:GetHandler():AddCounter(0x100e,1)
	end
end
function c213160.wfilter(c)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE)
end
function c213160.wcounter(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c213160.wfilter,1,nil) then
		e:GetHandler():AddCounter(0xf,1)
	end
end
function c213160.athfilter1(c,tp)
	local lv=c:GetLevel()
	return (c:IsLocation(LOCATION_DECK)) and lv>0 and c:IsSetCard(0xc)
		and Duel.IsCanRemoveCounter(tp,1,1,0x100e,lv,REASON_COST) and c:IsAbleToHand()
end
function c213160.athtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c213160.athfilter1,tp,LOCATION_DECK,0,1,nil,tp) end
	local g=Duel.GetMatchingGroup(c213160.athfilter1,tp,LOCATION_DECK,0,nil,tp)
	local lvt={}
	local tc=g:GetFirst()
	while tc do
		local tlv=tc:GetLevel()
		lvt[tlv]=tlv
		tc=g:GetNext()
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(213160,2))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	Duel.RemoveCounter(tp,1,1,0x100e,lv,REASON_COST)
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c213160.athfilter2(c,lv)
	return (c:IsLocation(LOCATION_DECK)) and c:IsSetCard(0xc)
		and c:IsLevel(lv) and c:IsAbleToHand()
end
function c213160.athop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c213160.athfilter2,tp,LOCATION_DECK,0,1,1,nil,lv)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c213160.wthfilter1(c,tp)
	local lv=c:GetLevel()
	return (c:IsLocation(LOCATION_DECK)) and lv>0 and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE)
		and Duel.IsCanRemoveCounter(tp,1,1,0xf,lv,REASON_COST) and c:IsAbleToHand()
end
function c213160.wthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c213160.wthfilter1,tp,LOCATION_DECK,0,1,nil,tp) end
	local g=Duel.GetMatchingGroup(c213160.wthfilter1,tp,LOCATION_DECK,0,nil,tp)
	local lvt={}
	local tc=g:GetFirst()
	while tc do
		local tlv=tc:GetLevel()
		lvt[tlv]=tlv
		tc=g:GetNext()
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(213160,3))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	Duel.RemoveCounter(tp,1,1,0xf,lv,REASON_COST)
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c213160.wthfilter2(c,lv)
	return (c:IsLocation(LOCATION_DECK)) and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE)
		and c:IsLevel(lv) and c:IsAbleToHand()
end
function c213160.wthop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c213160.wthfilter2,tp,LOCATION_DECK,0,1,1,nil,lv)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end