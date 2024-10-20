--[[
Invernal of the War Horn
Invernale del Corno di Guerra
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[At the end of a Battle Phase in which an "Invernal" monster or a DARK Xyz Monster you controlled was destroyed by battle or by an opponent's card effect:
	You can reveal this card in your hand; Special Summon this card, and if you do, Special Summon as many monsters from your GY as possible that were destroyed during this Battle Phase.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		s.spcon,
		aux.RevealSelfCost(),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can banish 2 "Invernal" monsters from your GY; for the next 3 turns after this effect resolves (counting the current one),
	all "Invernal" monsters and DARK Xyz Monsters you control cannot be destroyed by battle or by card effects.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetFunctions(
		nil,
		aux.BanishCost(aux.MonsterFilter(Card.IsSetCard,ARCHE_INVERNAL),LOCATION_GRAVE,0,2),
		aux.DummyCost,
		s.operation
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[A DARK "Number" Xyz Monster that has this card as material gains this effect.
	● If another card(s) you control would be destroyed by battle, or leave the field because of an opponent's card effect, you can detach 1 material from this card instead.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.xmatcon)
	e3:SetTarget(s.xmattg)
	e3:SetOperation(s.xmatop)
	e3:SetValue(s.xmatval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SEND_REPLACE)
	e4:SetTarget(s.xmattg2)
	e4:SetValue(s.xmatval2)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regfilter(c,tp)
	return c:IsPreviousSetCard(ARCHE_INVERNAL) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:IsPreviousPosition(POS_FACEUP) or (c:IsPreviousTypeOnField(TYPE_XYZ) and c:IsPreviousAttributeOnField(ATTRIBUTE_DARK)))
		and ((c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp) or c:IsReason(REASON_BATTLE))
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local g=eg:Filter(s.regfilter,nil,p)
		if #g>0 then
			Duel.RegisterFlagEffect(p,id,RESET_PHASE|PHASE_BATTLE,0,1)
		end
	end
	for tc in aux.Next(eg) do
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end
end

--E1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.PlayerHasFlagEffect(tp,id)
end
function s.spfilter(c,e,tp)
	return c:HasFlagEffect(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>0
	end
	local ct=math.min(Duel.GetMZoneCount(tp)-1,#g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g+c,ct+1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		local ft=Duel.GetMZoneCount(tp)
		local g=Duel.Group(aux.Necro(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		if ft>0 and #g>0 then
			if #g>ft then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				g=g:Select(tp,ft,ft,nil)
			end
			for tc in aux.Next(g) do
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	Duel.SpecialSummonComplete()
end

--E2
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.pcfilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END,3)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	Duel.RegisterEffect(e2,tp)
	Duel.RegisterHint(tp,id+100,RESET_PHASE|PHASE_END,3,id,3,nil,e1)
	aux.ManagePyroClockInteraction(c,tp,nil,PHASE_END,3,nil,nil,e1,e2)
end
function s.pcfilter(e,c)
	return c:IsSetCard(ARCHE_INVERNAL) or (c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK))
end

--E3
function s.xmatcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.repfilter(c,tp,h)
	return c:IsControler(tp) and c:IsOnField() and c~=h and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:IsReasonPlayer(1-tp))) and not c:IsReason(REASON_REPLACE)
end
function s.xmattg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp,c) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT|REASON_REPLACE) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		return true
	else
		return false
	end
end
function s.xmatval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer(),e:GetHandler())
end
function s.xmatop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT|REASON_REPLACE)
end

--E4
function s.repfilter2(c,tp,h)
	return c:IsControler(tp) and c:IsOnField() and c~=h and c:IsReason(REASON_EFFECT) and c:IsReasonPlayer(1-tp) and not c:IsReason(REASON_REPLACE|REASON_DESTROY) and c:GetDestination()&LOCATION_ONFIELD==0
end
function s.xmattg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter2,1,nil,tp,c) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT|REASON_REPLACE) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		return true
	else
		return false
	end
end
function s.xmatval2(e,c)
	return s.repfilter2(c,e:GetHandlerPlayer(),e:GetHandler())
end