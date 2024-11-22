--[[
Manaseal Word - Silence
Parola Manasigillo - Silenzio
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--If you control a "Manaseal" monster, you can activate this card from your hand.
	c:TrapCanBeActivatedFromHand(s.handactcon,aux.Stringid(id,5))
	--[[Activate 1 of these effects.
	● Negate the effects of all face-up Spells currently on the field until the end of this turn. Neither player can activate Spell Cards or effects in response to this effect's activation.
	● Special Summon 1 "Manaseal" monster from your hand, and if you do, destroy 1 Spell on the field.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If you control "Manaseal Rune Weaving" while this card is in your GY, apply the following effect.
	● Negate the effect of your opponent's third Spell Card or effect that resolves each turn while this effect is applying, and if you do, or if it did not have an effect, banish that card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.negcon2)
	e2:SetOperation(s.negop2)
	c:RegisterEffect(e2)
end
function s.handactcon(e)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_MANASEAL),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--E1
function s.disfilter(c)
	return c:IsSpell() and aux.NegateAnyFilter(c)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_MANASEAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSpell()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local dg=Duel.Group(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local b1=#g>0
	local b2=Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and #dg>0
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,id,1,b1,b2)
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
		Duel.SetChainLimit(function (_e,_rp,_tp)
			return not _e:IsActiveType(TYPE_SPELL)
		end)
	elseif opt==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,PLAYER_ALL,LOCATION_ONFIELD)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if opt==0 then
		local c=e:GetHandler()
		local g=Duel.Group(s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):Filter(Card.IsCanBeDisabledByEffect,nil,e)
		if #g>0 then
			Duel.Negate(g,e,0,false,false,TYPE_SPELL)
		end
	elseif opt==1 then
		if Duel.GetMZoneCount(tp)<=0 then return end
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			local dg=Duel.Select(HINTMSG_DESTROY,false,tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #dg>0 then
				Duel.HintSelection(dg)
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end

--E2
function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	return (not Duel.PlayerHasFlagEffect(tp,id) or Duel.GetFlagEffectLabel(tp,id)<3)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_MANASEAL_RUNE_WEAVING),tp,LOCATION_ONFIELD,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_SPELL)
end
function s.negop2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not Duel.PlayerHasFlagEffect(tp,id) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	end
	Duel.UpdateFlagEffectLabel(tp,id)
	local ct=Duel.GetFlagEffectLabel(tp,id)
	if ct==3 then
		if Duel.IsChainDisablable(ev) then
			Duel.Hint(HINT_CARD,tp,id)
			if Duel.NegateEffect(ev) and rc:IsRelateToChain(ev) then
				Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end