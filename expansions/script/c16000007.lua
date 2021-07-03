--E-Booktreeworm
function c16000007.initial_effect(c)
		 --evolute procedure
	aux.AddOrigEvoluteType(c)
	aux.AddEvoluteProc(c,nil,8,c16000007.filter1,2)
	c:EnableReviveLimit() 
  --atk up
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(c16000007.atkcon)
	e2:SetCost(c16000007.atkcost)
	e2:SetOperation(c16000007.atkop)
	c:RegisterEffect(e2)
 local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_LEAVE_FIELD_P)
	e5:SetOperation(c16000007.checkop)
	c:RegisterEffect(e5)
 local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16000007,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetCondition(c16000007.sccon)
	e3:SetOperation(c16000007.scop)
	c:RegisterEffect(e3)
 --activate limit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0xff,0xff)
	  e5:SetTarget(c16000007.atktg)
	e4:SetValue(c16000007.actlimit)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	 e5:SetTarget(c16000007.atktg2)
	c:RegisterEffect(e5)
 --disable
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(c16000007.atktg2)
	e6:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e6)
end


function c16000007.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_CYBERSE) 
end

function c16000007.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:GetSequence()>=5 and c:IsSummonType(SUMMON_TYPE_SPECIAL+388) and  bc 
end
function c16000007.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(16000007)==0 end
	c:RegisterFlagEffect(16000007,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function c16000007.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() then
		   local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e3:SetValue(c:GetAttack()*2)
		c:RegisterEffect(e3)
	end
end
function c16000007.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetEC()>0 then
		c:RegisterFlagEffect(16000007,RESET_EVENT+0x17a0000,0,0)
	end
end
function c16000007.sccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:GetFlagEffect(16000007)>0
end
function c16000007.filter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
end
function c16000007.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16000007.filter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c16000007.scop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c16000007.filter,tp,LOCATION_GRAVE,0,1,1,c)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	 Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
function c16000007.atktg(e,c)
	local c=e:GetHandler()
	return   c:GetMutualLinkedGroupCount()~=0
end
function c16000007.atktg2(e,c)
	return c:GetMutualLinkedGroupCount()~=0
end
function c16000007.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end