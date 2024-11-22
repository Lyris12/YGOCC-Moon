--[[
Manaseal Obelisk
Obelisco Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Each time your opponent activates a Spell Card or effect, immediately after it resolves, inflict 400 damage to them.]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.damcon)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	--[[During your Main Phase, if you control a "Manaseal" or DARK Xyz Monster, or if a Spell Card or effect was successfully activated this turn: You can Special Summon this card from your hand, and
	if you do, send 1 Normal Trap from your Deck to the GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:HOPT()
	e2:SetFunctions(
		aux.OR(aux.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1),s.spcon),
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
	--[[During your opponent's turn (Quick Effect): You can banish up to 4 Spells from your opponent's GY; Special Summon an equal number of "Manaseal" monsters from your hand and/or GY in Defense
	Position, and if you do, immediately after this effect resolves, their Levels become 8.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetRelevantTimings()
	e3:SetFunctions(
		aux.TurnPlayerCond(1),
		aux.DummyCost,
		s.sptg2,
		s.spop2
	)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.regop_global)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.regop_global(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.PlayerHasFlagEffect(0,id) and re:IsActiveType(TYPE_SPELL) then
		Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
	end
end

--E0 and E1
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and re:IsActiveType(TYPE_SPELL) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_FACEDOWN|RESET_CHAIN,0,1)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c:GetFlagEffect(id)~=0 and re:IsActiveType(TYPE_SPELL)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(1-tp,400,REASON_EFFECT)
end

--E2
function s.cfilter(c)
	return c:IsFaceup() and (c:IsSetCard(ARCHE_MANASEAL) or (c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(ARCHE_NUMBER) and c:IsType(TYPE_XYZ)))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.PlayerHasFlagEffect(0,id)
end
function s.tgfilter(c)
	return c:IsNormalTrap() and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

--E3
function s.rmcfilter(c)
	return c:IsSpell() and c:IsAbleToRemoveAsCost()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_MANASEAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetMZoneCount(tp)
	local g=Duel.Group(s.rmcfilter,tp,0,LOCATION_GRAVE,nil)
	local spg=Duel.Group(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		return e:IsCostChecked() and ft>0 and #g>0 and #spg>0
	end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		ft=math.min(1,ft)
	end
	local max=math.min(ft,#spg)
	local rg=g:Select(tp,1,max,nil)
	local ct=Duel.Remove(rg,POS_FACEUP,REASON_COST)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTargetParam()
	local ft=Duel.GetMZoneCount(tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		ft=math.min(1,ft)
	end
	if ct>ft then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,ct,ct,nil,e,tp)
	if #g==ct and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)==ct then
		local og=Duel.GetOperatedGroup():Filter(aux.FaceupFilter(Card.IsLocation,LOCATION_MZONE),nil)
		local eid=e:GetFieldID()
		og:ForEach(Card.RegisterFlagEffect,id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,eid)
		aux.ApplyEffectImmediatelyAfterResolution(s.lvop,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp):SetLabel(eid)
	end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp,_e,chain_end)
	local c=e:GetHandler()
	local g=Duel.Group(Card.HasFlagEffectLabel,tp,LOCATION_MZONE,LOCATION_MZONE,nil,id,_e:GetLabel())
	g:ForEach(
		function(tc)
			tc:ChangeLevel(8,true,{c,true})
			tc:ResetFlagEffect(id)
		end
	)
end