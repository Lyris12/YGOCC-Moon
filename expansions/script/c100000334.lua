--[[
Manaseal Prefect
Prefetto Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--[[If this card is in your hand: You can banish 1 Spell from either GY; Special Summon this card, and if you do, Set 1 "Manaseal Rune Weaving" directly from your hand, Deck, or GY. If you
	banished a Spell from your GY to activate this effect, that Set card can be activated this turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		aux.CreateCost(
			aux.BanishCost(s.cfilter,LOCATION_GRAVE,LOCATION_GRAVE,1),
			s.costchk
		),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[When your opponent activates a Spell Card or effect (Quick Effect): You can either Tribute this card or detach 1 material from an Xyz Monster on the field; negate the activation, and if you
	do, destroy that card, then this card gains 800 ATK until the end of this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY|CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		s.discon,
		s.discost,
		s.distg,
		s.disop
	)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c,_,tp)
	return c:IsSpell() and c:IsAbleToRemoveAsCost() and Duel.IsExists(false,s.setfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,c)
end
function s.setfilter(c)
	return c:IsST() and c:IsCode(CARD_MANASEAL_RUNE_WEAVING) and c:IsSSetable()
end
function s.costchk(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=Duel.GetGroupOperatedByThisCost(e):GetFirst()
	if tc and tc:IsSpell() and tc:IsPreviousLocation(LOCATION_GRAVE) then
		Duel.SetTargetParam(1)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and (e:IsCostChecked() or Duel.IsExists(false,s.setfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,c))
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Select(HINTMSG_SET,false,tp,aux.Necro(s.setfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SSetAndFastActivation(tp,g,e,Duel.GetTargetParam()==1)
		end
	end
end

--E2
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return rp==1-tp and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local b1=c:IsReleasable()
	local b2=g:CheckRemoveOverlayCard(tp,1,REASON_COST)
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,nil,nil,{b1,STRING_RELEASE},{b2,STRING_DETACH})
	if opt==0 then
		Duel.Release(c,REASON_COST)
	elseif opt==1 then
		g:RemoveOverlayCard(tp,1,1,REASON_COST)
	end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,LOCATION_MZONE,800)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)~=0 and c:IsRelateToChain() and c:IsFaceup() then
		c:UpdateATK(800,RESET_PHASE|PHASE_END,c)
	end
end