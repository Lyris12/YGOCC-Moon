--Infinte Gem- Space
function c249000935.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c249000935.condition)
	e1:SetTarget(c249000935.target)
	e1:SetOperation(c249000935.activate)
	c:RegisterEffect(e1)
	--move zone
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c249000935.seqtg)
	e2:SetOperation(c249000935.seqop)
	c:RegisterEffect(e2)
end
function c249000935.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()==PHASE_BATTLE_START or Duel.GetCurrentPhase()==PHASE_BATTLE_STEP)
end
function c249000935.tgfilter(c)
	local lv=4
	if c:GetOriginalLevel()>0 then lv=c:GetOriginalLevel() end
	return c:IsFaceup() and Duel.IsPlayerCanSpecialSummonMonster(tp,86871615,0,0x4011,c:GetBaseAttack(),c:GetBaseDefense(),
			lv,c:GetOriginalRace(),c:GetOriginalAttribute())
end
function c249000935.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(c249000935.tgfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 end
	Duel.SelectTarget(tp,c249000935.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
end
function c249000935.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lv=4
		if tc:GetOriginalLevel()>0 then lv=tc:GetOriginalLevel() end
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,86871615,0,0x4011,tc:GetBaseAttack(),tc:GetBaseDefense(),
			lv,tc:GetOriginalRace(),tc:GetOriginalAttribute())  then return end
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		for i=1,ft do
			local token=Duel.CreateToken(tp,86871615)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(tc:GetBaseAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_BASE_DEFENSE)
			e2:SetValue(tc:GetBaseDefense())
			token:RegisterEffect(e2)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CHANGE_LEVEL)
			e3:SetValue(lv)
			token:RegisterEffect(e3)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_CHANGE_RACE)
			e4:SetValue(tc:GetOriginalRace())
			token:RegisterEffect(e4)
			local e5=e1:Clone()
			e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e5:SetValue(tc:GetOriginalAttribute())
			token:RegisterEffect(e5)
			--damage 0
			local e6=Effect.CreateEffect(e:GetHandler())
			e6:SetType(EFFECT_TYPE_SINGLE)
			e6:SetCode(EFFECT_NO_BATTLE_DAMAGE)
			e6:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e6)
			local e7=e6:Clone()
			e7:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
			token:RegisterEffect(e7)
			local de=Effect.CreateEffect(e:GetHandler())
			de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			de:SetRange(LOCATION_MZONE)
			de:SetCode(EVENT_PHASE+PHASE_BATTLE)
			de:SetOperation(c249000935.desop)
			de:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(de)
		end
		Duel.SpecialSummonComplete()
	end
end
function c249000935.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then Duel.Exile(e:GetHandler(),REASON_RULE) end
end
function c249000935.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(92204263,1))
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function c249000935.seqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,571)
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	Duel.MoveSequence(tc,nseq)
end