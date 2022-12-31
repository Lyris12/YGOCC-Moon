--Mysterious Cluster Dragon
function c53313926.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--P: When a card you control is destroyed by battle or an opponent's card effect: You can Special Summon this card from your Pandemonium Zone.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCondition(c53313926.descon)
	e1:SetTarget(c53313926.destg)
	e1:SetOperation(c53313926.desop)
	c:RegisterEffect(e1)
	aux.EnablePandemoniumAttribute(c,e1,false,TYPE_EFFECT+TYPE_XYZ)
	--Materials: 3+ Level 9 monsters
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,9,3,nil,nil,99)
	--M: If this card has a "Mysterious" Xyz or Pandemonium Monster as Xyz Material, it gains this effect. Once per turn (Quick Effect): You can detach 1 material from this card; destroy 1 monster your opponent controls, and if you do, this card gains that monster's original effects (if any) and half of it's original ATK. 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+0x1c0)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e2:SetDescription(1131)
	e2:SetCondition(c53313926.condition)
	e2:SetCost(c53313926.cost)
	e2:SetTarget(c53313926.target)
	e2:SetOperation(c53313926.activate)
	c:RegisterEffect(e2)
	--M: While this card has no material attached to it, your opponent cannot target another card you control with card effects.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetCondition(function(e) return e:GetHandler():GetOverlayCount()==0 end)
	e2:SetTarget(function(e,c) return c~=e:GetHandler() end)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--M: If this card in the Monster Zone is destroyed by battle or card effect: You can Set it into your Spell/Trap Zone.
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_DESTROYED)
	e7:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler() return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) end)
	e7:SetTarget(c53313926.pentg)
	e7:SetOperation(c53313926.penop)
	c:RegisterEffect(e7)
end
--If you can Pandemonium Summon Level 9 monsters, you can Pandemonium Summon this face-up card from your Extra Deck.
c53313926.pandemonium_level=9
function c53313926.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetReasonPlayer()~=tp
end
function c53313926.descon(e,tp,eg,ep,ev,re,r,rp)
	return aux.PandActCheck(e) and eg:GetCount()==1 and eg:IsExists(c53313926.spcfilter,1,nil,tp)
end
function c53313926.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end
function c53313926.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c53313926.cfilter(c)
	return c:IsType(TYPE_XYZ+TYPE_PANDEMONIUM) and c:IsSetCard(0xcf6)
end
function c53313926.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated() and e:GetHandler():GetOverlayGroup():IsExists(c53313926.cfilter,1,nil)
end
function c53313926.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c53313926.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function c53313926.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		local atk=0
		if tc:GetBaseAttack()>0 then atk=tc:GetBaseAttack() end
		if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
		local c=e:GetHandler()
		c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+0x1ff0000)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+0x1ff0000)
		c:RegisterEffect(e1)
	end
end
function c53313926.cfilter(c,tp)
	return c:IsControler(tp) and Duel.IsExistingMatchingCard(c53313926.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function c53313926.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function c53313926.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c53313926.cfilter,1,nil,tp) end
	local g=Duel.SelectReleaseGroup(tp,c53313926.cfilter,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end
function c53313926.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,c53313926.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end
function c53313926.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and aux.PandSSetCon(e:GetHandler(),nil,e:GetHandler():GetLocation(),e:GetHandler():GetLocation())(nil,e,tp,eg,ep,ev,re,r,rp) end
end
function c53313926.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and aux.PandSSetCon(e:GetHandler(),nil,e:GetHandler():GetLocation(),e:GetHandler():GetLocation())(nil,e,tp,eg,ep,ev,re,r,rp) then
		aux.PandSSet(c,REASON_EFFECT,TYPE_EFFECT+TYPE_XYZ)(e,tp,eg,ep,ev,re,r,rp)
		Duel.ConfirmCards(1-tp,c)
	end
end
