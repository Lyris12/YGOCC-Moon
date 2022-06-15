--Comandamento Ængelico
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	--
	c:SummonedFieldTrigger(false,false,true,false,3,CATEGORY_TOHAND,true,LOCATION_GRAVE,{1,0},aux.EventGroupCond(s.cf),s.thcost,s.thtg,s.thop)
	--
	c:SSCounter(s.counterfilter)
end
function s.counterfilter(c)
	return c:IsSetCard(0xae6)
end

function s.filter(c,e,tp)
	return c:IsSetCard(0xae6) and c:IsMonster() and c:HasLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetLevel()<=Duel.GetFieldGroup(tp,LOCATION_REMOVED,0):FilterCount(Card.IsFacedown,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lim=aux.SSLimit(s.counterfilter,2,true)
	if chk==0 then return lim(e,tp,eg,ep,ev,re,r,rp,chk) end
	lim(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,nil,POS_FACEDOWN)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=g:Select(tp,1,#g,nil)
		if #rg>0 then
			Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
		end
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.cf(c,_,tp)
	return c:IsMonster(TYPE_TIMELEAP) and c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lim=aux.SSLimit(s.counterfilter,2,true)
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return lim(e,tp,eg,ep,ev,re,r,rp,chk) and #g>=3 and g:IsExists(Card.IsAbleToRemoveAsCost,#g,nil,POS_FACEDOWN) end
	lim(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end