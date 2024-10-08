--Amethyst-Wing Shaolong
local ref=_G['c'..171000118]
function c171000118.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c171000118.splimit)
	c:RegisterEffect(e1)
	--pendulum set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,171000118)
	e2:SetCondition(c171000118.pencon)
	e2:SetTarget(c171000118.pentg)
	e2:SetOperation(c171000118.penop)
	c:RegisterEffect(e2)
	--spsummon
	local e2x=Effect.CreateEffect(c)
	e2x:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2x:SetType(EFFECT_TYPE_QUICK_O)
	e2x:SetCode(EVENT_FREE_CHAIN)
	e2x:SetRange(LOCATION_PZONE)
	e2x:SetCountLimit(1,171000118)
	e2x:SetTarget(c171000118.sptg)
	e2x:SetOperation(c171000118.spop)
	c:RegisterEffect(e2x)
	--cannot be used as material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)
	--swap attack target
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(171000118,0))
	e7:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCode(EVENT_BE_BATTLE_TARGET)
	e7:SetCountLimit(1,171000118)
	e7:SetTarget(ref.attgtg)
	e7:SetOperation(ref.attgop)
	c:RegisterEffect(e7)
	--Negate own attack
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e8:SetDescription(aux.Stringid(171000118,0))
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e8:SetCode(EVENT_ATTACK_ANNOUNCE)
	e8:SetCountLimit(1,171000118)
	e8:SetCondition(ref.atcon)
	e8:SetTarget(ref.attg)
	e8:SetOperation(ref.atop)
	c:RegisterEffect(e8)
	--selfdestroy
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(171000118,2))
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e9:SetCode(EVENT_PHASE+PHASE_END)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCountLimit(1)
	e9:SetCondition(ref.sdcon)
	e9:SetOperation(ref.sdop)
	c:RegisterEffect(e9)
end
function c171000118.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xfef) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function c171000118.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_PZONE)
end
function c171000118.penfilter(c)
	return c:IsSetCard(0xfef) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c171000118.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(c171000118.penfilter,tp,LOCATION_DECK,0,1,nil) 
	end
end
function c171000118.penop(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,c171000118.penfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c171000118.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_PZONE,0,c,0xfef)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c171000118.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,c,0xfef)
	if tc and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function ref.rdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfef) and c:IsType(TYPE_MONSTER)
end
function ref.attgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and ref.rdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(ref.rdfilter,tp,LOCATION_MZONE,0,1,c) end
	Duel.SelectTarget(tp,ref.rdfilter,tp,LOCATION_MZONE,0,1,1,c)
	c:RegisterFlagEffect(171000118,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function ref.attgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local a=Duel.GetAttacker()
	local ag=a:GetAttackableTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if a:GetAttack()>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e1:SetValue(math.floor(a:GetAttack()/2))
		tc:RegisterEffect(e1)
	end
	if a:GetDefense()>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e1:SetValue(math.floor(a:GetDefense()/2))
		tc:RegisterEffect(e1)
	end
	if a:IsAttackable() and not a:IsImmuneToEffect(e) and ag:IsContains(tc) then
		Duel.BreakEffect()
		Duel.ChangeAttackTarget(tc)
	end
end

function ref.atcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()~=nil and Duel.GetAttackTarget():IsFaceup() and (Duel.GetAttackTarget():GetAttack()>0 or Duel.GetAttackTarget():GetDefense()>0)
end
function ref.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and ref.rdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(ref.rdfilter,tp,LOCATION_MZONE,0,1,c) end
	Duel.NegateAttack()
	local ac=Duel.SelectTarget(tp,ref.rdfilter,tp,LOCATION_MZONE,0,1,1,c)
	Duel.GetAttackTarget():RegisterFlagEffect(171000118,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE_START,0,1)
	c:RegisterFlagEffect(171000118,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function ref.atkfilter(c)
	return c:GetFlagEffect(171000118)~=0 and c:IsFaceup()
end
function ref.atop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local a=Duel.GetMatchingGroup(ref.atkfilter,tp,0,LOCATION_MZONE,nil):GetFirst()
	if a and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		if a:GetAttack()>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			e1:SetValue(math.floor(a:GetAttack()/2))
			tc:RegisterEffect(e1)
		end
		if a:GetDefense()>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_DEFENSE)
			e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			e1:SetValue(math.floor(a:GetDefense()/2))
			tc:RegisterEffect(e1)
		end
	end
end
function ref.sdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(171000118)>0
end
function ref.sdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end