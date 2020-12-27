--Lotus Blade Adept - Kyrie
--Commissioned by: Leon Duvall
--Scripted by: Remnance
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.setcost)
	e1:SetTarget(cid.settg)
	e1:SetOperation(cid.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+17)
	e3:SetCondition(cid.spcon)
	e3:SetCost(cid.spcost)
	e3:SetTarget(cid.sptg)
	e3:SetOperation(cid.spop)
	c:RegisterEffect(e3)
end
--filters
function cid.setfilter(c)
	return c:IsSetCard(0x3ff) and c:IsType(TYPE_SPELL) and c:IsSSetable()
		and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or c:IsType(TYPE_FIELD))
end
function cid.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x3ff) and c:IsType(TYPE_SPELL)
		and Duel.IsExistingMatchingCard(cid.cfilter2,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
function cid.cfilter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
function cid.cfilter2(c,code)
	return c:IsFaceup() and c:IsSetCard(0x3ff) and c:IsType(TYPE_SPELL) and not c:IsCode(code)
end
function cid.costfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x3ff) and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x3ff) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)
end
function cid.thfilter(c)
	return c:IsSetCard(0x3ff) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
--set
function cid.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function cid.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function cid.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,cid.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
		Duel.ConfirmCards(1-tp,g)
	end
end
--spsummon
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) and not Duel.IsExistingMatchingCard(cid.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.costfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	local g=Duel.GetMatchingGroup(cid.costfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
	Duel.SendtoGrave(tc,REASON_COST)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)~=0 then
	tc:CompleteProcedure()
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		  if g1:GetCount()>0 then
			 Duel.SendtoHand(g1,nil,REASON_EFFECT)
			 Duel.ConfirmCards(1-tp,g1)
	  end
   end
end
