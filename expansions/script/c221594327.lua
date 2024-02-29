--[[
Voidictator Energy - Fundamental Essence
Energia dei Vuotodespoti - Essenza Fondamentale
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Voidictator Energy - Fundamental Essence".
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:HOPT(true)
	c:RegisterEffect(e0)
	--[[During your Main Phase: You can banish 3 "Voidictator Servant" monsters from your field or GY; Special Summon 1 "Voidictator Deity" or "Voidictator Demon" monster from your Extra Deck, ignoring its Summoning conditions (this Special Summon is treated as the respective Summon Mechanic),
	then if you Special Summoned an Xyz Monster this way, attach 3 of your banished cards to it as material.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Each turn, the first and second time this face-up card would be destroyed by a card effect, it is not destroyed.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	--If this card is banished by a "Voidictator" card you own: Shuffle this card into the Deck, and if you do, banish 1 Set card your opponent controls.
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_TODECK|CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and (c:IsLocation(LOCATION_MZONE) or c:IsMonsterCard()) and c:IsSetCard(ARCHE_VOIDICTATOR_SERVANT) and c:IsAbleToRemoveAsCost()
end
function s.gcheck(g,e,tp)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
function s.spfilter(c,e,tp,g)
	local sumtype=c:GetMechanicSummonType()
	return sumtype~=0 and c:IsSetCard(ARCHE_VOIDICTATOR_DEITY,ARCHE_VOIDICTATOR_DEMON) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0 and c:IsCanBeSpecialSummoned(e,sumtype,tp,true,false)
		and (not c:IsType(TYPE_XYZ) or Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,LOCATION_REMOVED,0,3,nil,tp))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.cfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,3,3,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3,e,tp)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		local sumtype=tc:GetMechanicSummonType()
		if Duel.SpecialSummon(tc,sumtype,tp,tp,true,false,POS_FACEUP)>0 and tc:IsType(TYPE_XYZ) and tc:IsFaceup() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
			local g=Duel.SelectMatchingCard(tp,Card.IsCanOverlay,tp,LOCATION_REMOVED,0,3,3,nil,tp)
			if #g==3 then
				Duel.HintSelection(g)
				Duel.BreakEffect()
				Duel.Attach(g,tc)
			end
		end	
	end
end

--E2
function s.indct(e,re,r,rp)
	if r&REASON_EFFECT>0 then
		return 2
	else
		return 0
	end
end

--E3
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	local g=Duel.Group(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c)>0
	and Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) then
		Duel.HintMessage(tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end