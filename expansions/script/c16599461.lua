--Ultimatum dell'Organizzazione Angeli
--Script by XGlitchy30
function c16599461.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_SPSUMMON)
	e1:SetTarget(c16599461.target)
	e1:SetOperation(c16599461.activate)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c16599461.spcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c16599461.sptg)
	e2:SetOperation(c16599461.spop)
	c:RegisterEffect(e2)
	--act in hand
	local hand=Effect.CreateEffect(c)
	hand:SetType(EFFECT_TYPE_SINGLE)
	hand:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	hand:SetCondition(c16599461.event_check)
	c:RegisterEffect(hand)
end
--filters
function c16599461.filter(c)
	return c:IsRace(RACE_FAIRY) and c:GetAttack()==0 and c:IsAbleToHand()
end
function c16599461.spcheck(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_FAIRY)
end
function c16599461.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1559)
end
function c16599461.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--Activate
function c16599461.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16599461.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c16599461.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c16599461.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--spsummon
function c16599461.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c16599461.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c16599461.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c16599461.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function c16599461.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c16599461.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		if Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)~=0 then
			if not g:GetFirst():IsSetCard(0x1559) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				g:GetFirst():RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				g:GetFirst():RegisterEffect(e2)
			end
		end
		Duel.SpecialSummonComplete()
	end
	--spsummon limit
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c16599461.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c16599461.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsType(TYPE_SYNCHRO)
end
--act in hand
function c16599461.event_check(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	local boolchk,evgroup,evplayer,evval,eveff_res,evreason,evplayer_res=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if boolchk then
		return evgroup:IsExists(c16599461.spcheck,1,nil) and ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL
	end
end