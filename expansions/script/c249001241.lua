--Space Time Rogue
function c249001241.initial_effect(c)
	c:SetUniqueOnField(1,0,249001241)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
	e1:SetCost(c249001241.spcost)
	e1:SetTarget(c249001241.sptg)
	e1:SetOperation(c249001241.spop)
	c:RegisterEffect(e1)
	--s/t set (battled)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_BATTLED)
	e2:SetTarget(c249001241.settg)
	e2:SetOperation(c249001241.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function c249001241.filter(c)
	return c:IsSetCard(0x235) and c:IsDiscardable()
end
function c249001241.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001241.filter,tp,LOCATION_HAND,0,2,nil) end
	Duel.DiscardHand(tp,c249001241.filter,2,2,REASON_COST+REASON_DISCARD)
end
function c249001241.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=2 then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function c249001241.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function c249001241.setfilter(c,e,tp)
	return (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(true) and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0))
		or (c:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and c:IsAttackBelow(800 * Duel.GetTurnCount()))
end
function c249001241.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c249001241.setfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c249001241.setfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,c249001241.setfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	if bit.band(g:GetFirst():GetOriginalType(),TYPE_MONSTER)~=0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_LEAVE_GRAVE)
	end
end
function c249001241.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			Duel.ConfirmCards(1-tp,tc)
		elseif (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and tc:IsSSetable() then
			Duel.BreakEffect()
			if Duel.SSet(tp,tc)~=0 then
				Duel.ConfirmCards(1-tp,tc)
				if tc:IsType(TYPE_TRAP) then
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
					e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
				end
				if tc:IsType(TYPE_QUICKPLAY) then
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
					e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
				end
			end	
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
	e:SetCategory(CATEGORY_LEAVE_GRAVE)
end