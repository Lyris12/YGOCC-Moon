--[[1 EARTH Tuner + 1+ non-Tuner EARTH Plant Monsters
If this card is Synchro Summoned by using 1 or more Synchro Monsters as materials, 
this card cannot be targeted or destroyed by your opponents card effects. During your 
opponents turn, the ATK of the first Monster(s) they Summon becomes 0, also, their effects 
are negated until the End Phase. If this card is destroyed by battle: Special Summon 1 "New 
Shinji, the Random Plantlord" from your Extra Deck. (This Special Summon is treated as a 
Synchro Summon.)]]

--Keddy was here~
function c79854540.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,c79854540.synfilter,aux.NonTuner(c79854540.synfilter),1)
	c:EnableReviveLimit()
	--untargetable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c79854540.scon)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c79854540.scon)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	--on the first stummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79854540,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(c79854540.atkcon)
	e3:SetTarget(c79854540.atktg)
	e3:SetOperation(c79854540.atkop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--float
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(79854540,1))
	e6:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetCode(EVENT_BATTLE_DESTROYED)
	e6:SetCondition(c79854540.sumcon)
	e6:SetTarget(c79854540.sumtg)
	e6:SetOperation(c79854540.sumop)
	c:RegisterEffect(e6)
end
--synchrocon
function c79854540.synfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end
--synchro as a material
function c79854540.scon(e,tp,eg,ep,ev,re,r,rp)
	local mg=e:GetHandler():GetMaterial()
	return #mg>0 and mg:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end
--on first Summon
function c79854540.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp) and Duel.GetTurnPlayer()~=tp
end
function c79854540.atkfilter(c)
	return c:IsFaceup()
end
function c79854540.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE+CATEGORY_DISABLE,eg,eg:GetCount(),0,0)
end
function c79854540.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=eg:Filter(c79854540.atkfilter,nil,e)
	if #g<=0 then return end
	for tc in aux.Next(g) do
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 and not tc:IsImmuneToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
--Float
function c79854540.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_BATTLE)
end
function c79854540.filter(c,e,tp)
	return c:IsCode(79854541) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,true)
end
function c79854540.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c79854540.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c79854540.sumop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstMatchingCard(c79854540.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tg then
		Duel.SpecialSummon(tg,SUMMON_TYPE_SYNCHRO,tp,tp,false,true,POS_FACEUP)
		tg:CompleteProcedure()
	end
end