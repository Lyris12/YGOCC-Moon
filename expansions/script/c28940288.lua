--Sunhewer of Magic, Fiera
local ref,id=GetID()
Duel.LoadScript("Sunhew.lua")
function ref.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,5)
	c:DriveEffect(0,0,CATEGORY_DESTROY,EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O,EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET,EVENT_ENGAGE,
		nil,
		nil,
		ref.destg,
		ref.desop
	)
	local d1=c:DriveEffect(0,0,0,EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS,nil,EVENT_LEAVE_FIELD,nil,nil,nil,
		ref.regop)
	c:DriveEffect(0,0,0,EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS,nil,EVENT_LEAVE_GRAVE,nil,nil,nil,ref.regop)
	----Monster Effects
	--Burn
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_DRAW_PHASE+TIMING_TOHAND)
	e3:SetCondition(function(e) local c=e:GetHandler()
		return c:IsSummonType(SUMMON_TYPE_DRIVE) or c:IsSummonType(SUMMON_TYPE_NORMAL) end)
	e3:SetTarget(ref.dmgtg)
	e3:SetOperation(ref.dmgop)
	c:RegisterEffect(e3)
	--Swap Field
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:HOPT()
	e4:SetCost(ref.spcost)
	e4:SetTarget(ref.sptg)
	e4:SetOperation(ref.spop)
	c:RegisterEffect(e4)
end

function ref.regfilter(c,tp)
	return c:GetPreviousControler()==1-tp and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==tp))
end
function ref.regop(e,tp,eg,rp,ev,re,r,rp) local c=e:GetHandler()
	local oen=c:GetEnergy()
	local en=math.min(eg:FilterCount(ref.regfilter,nil,tp),6-oen)
	if en>0 then c:UpdateEnergy(en,tp,REASON_EFFECT,true) end
end

--Destroy
function ref.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function ref.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(function(e,re,val,r,rp,rc) return math.max(val-500,0) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

--Ban
function ref.dmgfilter(c) return c:IsFaceup() and c:IsAttackAbove(1) end
function ref.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(ref.dmgfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,ref.dmgfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
function ref.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and ref.dmgfilter(tc) then
		local val=tc:GetAttack()
		if tc:IsLocation(LOCATION_GRAVE) then val=math.floor(val/2) end
		Duel.Damage(1-tp,val,REASON_EFFECT)
	end
end

--Swap Field
function ref.spcost(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function ref.spfilter(c,e,tp)
	return Sunhew.Is(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function ref.sptg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(ref.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,1,nil,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,1,nil,tp,LOCATION_MZONE)
end
function ref.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(ref.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 then Duel.BreakEffect() Duel.SendtoGrave(g,REASON_EFFECT) end
	end
end
