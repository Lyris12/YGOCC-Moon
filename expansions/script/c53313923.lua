--Mysterious Supernova Dragon
function c53313923.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--You can target 1 monster you control, except during the Battle Phase; destroy all monsters on the field with a different Attribute than that monster, then destroy this card, and if you do, neither player takes damage until the end of the opponent's next turn. (HOPT1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_SZONE)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCategory(CATEGORY_DESTROY)
	e0:SetCountLimit(1,53313923)
	e0:SetCondition(aux.PandActCheck)
	e0:SetTarget(c53313923.target)
	e0:SetOperation(c53313923.operation)
	c:RegisterEffect(e0)
	aux.EnablePandemoniumAttribute(c,e0,false,TYPE_EFFECT+TYPE_FUSION)
	--Materials: 1 "Mysterious" Dragon monster + 1 LIGHT monster
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),c53313923.ffilter,false)
	--Must be Fusion Summoned by banishing the above monsters you control or face-up in your Extra Deck. (You do not use "Polymerization").
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c53313923.sprcon)
	e2:SetOperation(c53313923.sprop)
	e2:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e2)
	--This card gains the monster effects of cards in your Pandemonium Zone.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c53313923.copy)
	c:RegisterEffect(e3)
	--Gains 300 ATK for every other Pandemonium Monster on the field.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetValue(c53313923.sdcon)
	c:RegisterEffect(e4)
	--If this card in the Monster Zone is destroyed by battle or card effect: You can Set it into your Spell/Trap Zone.
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c53313923.repcon)
	e5:SetTarget(c53313923.reptg)
	e5:SetOperation(c53313923.repop)
	c:RegisterEffect(e5)
end
function c53313923.splimit(e,se,sp,st)
	return not se or aux.fuslimit(e,se,sp,st)
end
function c53313923.dfilter(c,at)
	return c:IsFaceup() and c:GetAttribute()~=at
end
function c53313923.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	local ph=Duel.GetCurrentPhase()
	if chk==0 then return not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	local dg=Duel.GetMatchingGroup(c53313923.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,g:GetFirst():GetAttribute())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
function c53313923.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not e:GetHandler():IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local dg=Duel.GetMatchingGroup(c53313923.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc:GetAttribute())
	if dg:GetCount()>0 and Duel.Destroy(dg,REASON_EFFECT)>0 and e:GetHandler():IsDestructable() then
		Duel.BreakEffect()
		if Duel.Destroy(e:GetHandler(),REASON_EFFECT)==0 then return end
		local ct=1
		if Duel.GetTurnPlayer()~=tp then ct=2 end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,ct)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,ct)
		Duel.RegisterEffect(e2,tp)
	end
end
function c53313923.ffilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsSetCard(0xcf6)
end
function c53313923.sprfilter1(c,fc,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_MZONE)) and c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost() and c:IsCanBeFusionMaterial(fc)
		and Duel.IsExistingMatchingCard(c53313923.sprfilter2,tp,0x46,0,1,Group.FromCards(c,fc),fc,c)
end
function c53313923.sprfilter2(c,fc,tc)
	return (c:IsFaceup() or c:IsLocation(LOCATION_MZONE)) and c:IsRace(RACE_DRAGON) and c:IsSetCard(0xcf6) and c:IsAbleToRemoveAsCost() and c:IsCanBeFusionMaterial(fc) and Duel.GetLocationCountFromEx(tp,tp,Group.FromCards(c,tc))>0
end
function c53313923.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return c:IsFacedown() and Duel.IsExistingMatchingCard(c53313923.sprfilter1,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,c,c,tp)
end
function c53313923.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,c53313923.sprfilter1,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,1,c,c,tp)
	local tc=g1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,c53313923.sprfilter2,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,1,Group.FromCards(c,tc),c,tc)
	g1:Merge(g2)
	Duel.Remove(g1,POS_FACEUP,REASON_COST+REASON_MATERIAL+REASON_FUSION)
end
function c53313923.filter2(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(c53313923.filter3,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,c:GetCode())
end
function c53313923.filter3(c,code)
	return not c:IsCode(code) and c:IsAbleToHand()
end
function c53313923.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313923.filter2,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function c53313923.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c53313923.filter2,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	local code=g:GetFirst():GetCode()
	e:GetHandler():CopyEffect(code,RESET_EVENT+0x1fe0000)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,c53313923.filter3,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,code)
		if sg:GetCount()>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
function c53313923.copy(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstMatchingCard(aux.PaCheckFilter,tp,LOCATION_SZONE,0,nil)
	if tc and tc:GetFlagEffect(53313923)==0 then
		e:GetHandler():CopyEffect(tc:GetOriginalCode(),RESET_EVENT+0x1fe0000+RESET_EVENT+EVENT_ADJUST)
		tc:RegisterFlagEffect(53313923,RESET_EVENT+0x1fe0000+RESET_EVENT+EVENT_ADJUST,EFFECT_FLAG_CANNOT_DISABLE,1)
	end
end
function c53313923.sdreq(c)
	return c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM)
end
function c53313923.sdcon(e)
	return Duel.GetMatchingGroupCount(c53313923.sdreq,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())*300
end
function c53313923.repcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function c53313923.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and aux.PandSSetCon(e:GetHandler(),nil,e:GetHandler():GetLocation(),e:GetHandler():GetLocation())(nil,e,tp,eg,ep,ev,re,r,rp) end
end
function c53313923.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and aux.PandSSetCon(e:GetHandler(),nil,e:GetHandler():GetLocation(),e:GetHandler():GetLocation())(nil,e,tp,eg,ep,ev,re,r,rp) then
		aux.PandSSet(tc,REASON_EFFECT,TYPE_EFFECT+TYPE_FUSION)(e,tp,eg,ep,ev,re,r,rp)
		Duel.ConfirmCards(1-tp,tc)
	end
end
