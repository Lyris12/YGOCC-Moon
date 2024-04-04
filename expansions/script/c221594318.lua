--[[
Voidictator Servant - Gate Magician
Servitore dei Vuotodespoti - Mago del Portale
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--This card cannot be used as a material for the Summon of a monster from the Extra Deck while it is on the field.
	aux.CannotBeEDMaterial(c,nil,LOCATION_ONFIELD,true)
	--[[While you control this card and 1 "Voidictator Deity" or "Voidictator Demon" monster, your opponent cannot control face-up Pandemonium Cards in their Pandemonium Zone.
	Send all face-up Pandemonium Cards in their Pandemonium Zone to the GY.]]
	local p1=Effect.CreateEffect(c)
	p1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	p1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCode(EVENT_ADJUST)
	p1:SetCondition(s.adjustcon)
	p1:SetOperation(s.adjustop)
	c:RegisterEffect(p1)
	local p1x=Effect.CreateEffect(c)
	p1x:SetType(EFFECT_TYPE_FIELD)
	p1x:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	p1x:SetCode(EFFECT_CANNOT_ACTIVATE)
	p1x:SetRange(LOCATION_SZONE)
	p1x:SetTargetRange(0,1)
	p1x:SetCondition(s.adjustcon)
	p1x:SetValue(s.aclimit)
	c:RegisterEffect(p1x)
	local p1y=Effect.CreateEffect(c)
	p1y:SetType(EFFECT_TYPE_FIELD)
	p1y:SetCode(EFFECT_CANNOT_PLACE_ON_FIELD)
	p1y:SetRange(LOCATION_SZONE)
	p1y:SetTargetRange(1,1)
	p1y:SetCondition(s.adjustcon)
	p1y:SetValue(s.pclimit)
	c:RegisterEffect(p1y)
	--[[Up to twice per turn: You can target 1 "Voidictator" card in your GY; banish it.]]
	local p2=Effect.CreateEffect(c)
	p2:Desc(0)
	p2:SetCategory(CATEGORY_REMOVE)
	p2:SetType(EFFECT_TYPE_QUICK_O)
	p2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	p2:SetRange(LOCATION_SZONE)
	p2:SetCode(EVENT_FREE_CHAIN)
	p2:SetCountLimit(2)
	p2:SetRelevantTimings()
	p2:SetCondition(aux.PandActCheck)
	p2:SetTarget(s.rmtg)
	p2:SetOperation(s.rmop)
	c:RegisterEffect(p2)
	aux.EnablePandemoniumAttribute(c,p2)
	--[[You can Special Summon this card (from your hand or face-up Extra Deck) by sending 1 "Voidictator Servant" monster you control to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetRange(LOCATION_HAND|LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can banish up to 2 "Voidictator" cards from your GY; this card gains 800 ATK for each card banished to activate this effect.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(nil,aux.DummyCost,s.atktg,s.atkop)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[If this card is banished because of a "Voidictator" card you own: You can either Set this card in your Spell & Trap Zone, or shuffle this card into the Deck.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(3)
	e3:SetCategory(CATEGORY_LEAVE_GRAVE|CATEGORY_TODECK|CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:HOPT()
	e3:SetFunctions(s.thcon,nil,s.thtg,s.thop)
	c:RegisterEffect(e3)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end

--P1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR_DEITY,ARCHE_VOIDICTATOR_DEMON)
end
function s.adjustcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.PandActCheck(e) and Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local g=Duel.GetMatchingGroup(Card.IsInPandemoniumZone,tp,0,LOCATION_SZONE,nil)
	local readjust=false
	if #g>0 then
		Duel.SendtoGrave(g,REASON_RULE,tp)
		readjust=true
	end
	if readjust then Duel.Readjust() end
end
function s.aclimit(e,re,tp)
	local p=e:GetHandlerPlayer()
	local rc=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsType(TYPE_PANDEMONIUM)
end
function s.pclimit(e,c,placer,receiver,loc,re,r)
	return c:IsType(TYPE_PANDEMONIUM) and receiver==e:GetHandlerPlayer() and loc&LOCATION_PANDEZONE>0
end

--P2
function s.rmfilter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

--E1
function s.spfilter(c,sc,from_extra)
	if not (c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR_SERVANT) and c:IsAbleToGraveAsCost()) then return false end
	if from_extra then
		return Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
	else
		return Duel.GetMZoneCount(tp,c)>0
	end
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,c,c:IsLocation(LOCATION_EXTRA))
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,c,c:IsLocation(LOCATION_EXTRA))
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end

--E2
function s.atkfilter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsAbleToRemoveAsCost()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() and c:IsCanChangeAttack() and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.atkfilter,tp,LOCATION_GRAVE,0,1,2,nil)
	if #g>0 then
		local val=Duel.Remove(g,POS_FACEUP,REASON_COST)*800
		Duel.SetTargetParam(val)
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,c:GetControler(),c:GetLocation(),val)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local val=Duel.GetTargetParam()
	if val and c:IsRelateToChain() and c:IsCanChangeAttack() then
		c:UpdateATK(val,0,c)
	end
end

--E3
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.thfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=c:IsPandemoniumSSetable()
	local b2=c:IsAbleToDeck()
	if chk==0 then return b1 or b2 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,c,1,c:GetControler(),c:GetLocation())
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local b1=c:IsPandemoniumSSetable()
	local b2=c:IsAbleToDeck()
	if not b1 and not b2 then return end
	local opt=aux.Option(tp,nil,nil,{b1,STRING_SET},{b2,STRING_SEND_TO_DECK})
	if opt==0 then
		Duel.PandSSet(c,e,tp,REASON_EFFECT)
	elseif opt==1 then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end