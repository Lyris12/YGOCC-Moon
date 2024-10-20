--[[
Invernal of the War Banner
Invernale dello Stendardo da Guerra
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[At the end of a Main Phase in which you Special Summoned a DARK "Number C" Xyz Monster: You can reveal this card in your hand;
	Special Summon this card, and if you do, attach all Special Summoned monsters your opponent controls to 1 DARK "Number" Xyz Monster you control as materials (if any).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCustomCategory(CATEGORY_ATTACH,CATEGORY_FLAG_END_OF_MP_TRIGGER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_MAIN_END)
	e1:HOPT()
	e1:SetFunctions(
		s.spcon,
		aux.RevealSelfCost(),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can target 1 DARK "Number" Xyz Monster you control; for the rest of this turn,
	it is unaffected by other card effects, except its own.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetFunctions(
		nil,
		nil,
		s.pttg,
		s.ptop
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[A DARK "Number" Xyz Monster that has this card attached to it as material gains this effect.
	● All other "Invernal" monsters you control gain 800 ATK/DEF for every 2 materials attached to this card.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.xmatcon)
	e3:SetTarget(s.xmattg)
	e3:SetValue(s.xmatval)
	c:RegisterEffect(e3)
	e3:UpdateDefenseClone(c)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAIN_CREATED)
		ge2:SetOperation(s.chainreg)
		Duel.RegisterEffect(ge2,0)
	end
end
function s.regfilter(c,p)
	return c:IsSummonPlayer(p) and c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER_C) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsMainPhase() then return end
	for p=0,1 do
		if eg:IsExists(s.regfilter,1,nil,p) then
			Duel.RegisterFlagEffect(p,id,RESET_PHASE|Duel.GetCurrentPhase(),0,1)
		end
	end
end

function s.chainreg(e,tp)
	if Duel.CheckTiming(TIMING_MAIN_END) then
		Duel.RegisterFlagEffect(0,id+100,RESET_CHAIN,0,1)
	end
end

--E1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.PlayerHasFlagEffect(tp,id) then return false end
	if Duel.GetTurnPlayer()==tp then
		if Duel.GetCurrentChain()==0 or Duel.PlayerHasFlagEffect(0,id+100) then return true end
		for i=1,Duel.GetCurrentChain() do
			local ce=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			if not ce:IsHasCustomCategory(nil,CATEGORY_FLAG_END_OF_MP_TRIGGER) then
				return false
			end
		end
		return true
	else
		return Duel.CheckTiming(TIMING_MAIN_END)
	end
end
function s.atfilter(c,e,tp,dg)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and dg:IsExists(Card.IsCanBeAttachedTo,1,nil,c,e,tp,REASON_EFFECT)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if Duel.IsMainPhase(tp) then
		Duel.SkipPhase(tp,Duel.GetCurrentPhase(),RESET_PHASE|Duel.GetCurrentPhase(),1)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	local g=Duel.Group(Card.IsSpecialSummoned,tp,0,LOCATION_MZONE,nil)
	local xyzg=Duel.Group(s.atfilter,tp,LOCATION_MZONE,0,nil,e,tp,g)
	if #g>0 then
		Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,g,#g,0,0,xyzg,1)
	else
		Duel.SetPossibleCustomOperationInfo(0,CATEGORY_ATTACH,g,#g,1-tp,LOCATION_MZONE,xyzg,1)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Group(Card.IsSpecialSummoned,tp,0,LOCATION_MZONE,nil)
		local xyzg=Duel.Group(s.atfilter,tp,LOCATION_MZONE,0,nil,e,tp,g)
		if #xyzg>0 then
			Duel.HintMessage(tp,HINTMSG_ATTACHTO)
			local xyz=xyzg:Select(tp,1,1,nil)
			Duel.HintSelection(xyz)
			xyz=xyz:GetFirst()
			local ag=g:Filter(Card.IsCanBeAttachedTo,nil,xyz,e,tp,REASON_EFFECT)
			Duel.Attach(ag,xyz,false,e,tp,REASON_EFFECT)
		end
	end
end

--E2
function s.ptfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and not c:HasFlagEffect(id)
end
function s.pttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.ptfilter(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.ptfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Select(HINTMSG_TARGET,true,tp,s.ptfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.ptop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local imchk=not tc:IsImmuneToEffect(e)
		local res=tc:Unaffected(UNAFFECTED_OTHER,nil,RESET_PHASE|PHASE_END,c,nil,nil,STRING_UNAFFECTED_BY_OTHER_EFFECT)
		if res and imchk then
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
		end
	end
end

--E3
function s.xmatcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.xmattg(e,c)
	return c:IsSetCard(ARCHE_INVERNAL) and c~=e:GetHandler()
end
function s.xmatval(e,c)
	local h=e:GetHandler()
	local ct=math.floor(h:GetOverlayCount()/2)
	return ct*800
end