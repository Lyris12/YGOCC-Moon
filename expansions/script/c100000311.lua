--[[
Invernal of the Silver Lance
Invernale della Lancia d'Argento
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	--[[If this card is sent to the GY: You can discard 1 card; Special Summon this card in Defense Position, then, if this card was sent to the GY
	because it was detached from a DARK "Number" Xyz Monster, gain LP equal to the highest ATK among DARK Xyz Monsters you control (your choice, if tied).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		s.spcon,
		aux.DiscardCost(),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can target 1 DARK Xyz Monster you control; attach the top 3 cards of your Deck to it as materials.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCustomCategory(CATEGORY_ATTACH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetFunctions(
		nil,
		nil,
		s.attg,
		s.atop
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[A DARK "Number" Xyz Monster that has this card attached to it as material gains this effect.
	● If this card attacks a Defense Position monster, inflict piercing battle damage. If that monster is a Special Summoned monster, inflict double piercing battle damage, instead.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetCondition(s.xmatcon)
	e3:SetValue(s.xmatval)
	c:RegisterEffect(e3)
end
--E1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local checkev,eg=Duel.CheckEvent(EVENT_DETACH_MATERIAL,true)
	if checkev and eg:IsExists(s.cfilter,1,nil) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	return true
end
function s.cfilter(c)
	return s.lpfilter(c) and c:IsSetCard(ARCHE_NUMBER)
end
function s.lpfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local checkev=e:GetLabel()==1
	if chk==0 then
		if not (Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)) then return false end
		if checkev then
			return Duel.IsExists(false,s.lpfilter,tp,LOCATION_MZONE,0,1,nil)
		else
			return true
		end
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	if checkev then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_RECOVER)
		Duel.SetTargetParam(1)
		local g=Duel.Group(s.lpfilter,tp,LOCATION_MZONE,0,nil)
		local _,val=g:GetMaxGroup(Card.GetAttack)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetTargetParam(0)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 and Duel.GetTargetParam()==1 then
		local g=Duel.Group(s.lpfilter,tp,LOCATION_MZONE,0,nil)
		if #g>0 then
			local _,val=g:GetMaxGroup(Card.GetAttack)
			Duel.BreakEffect()
			Duel.Recover(tp,val,REASON_EFFECT)
		end
	end
end

--E2
function s.atfilter(c,e,tp,dg)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and dg:IsExists(Card.IsCanBeAttachedTo,1,nil,c,e,tp,REASON_EFFECT)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local dg=Duel.GetDecktopGroup(tp,3)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atfilter(chkc,e,tp,dg) end
	if chk==0 then
		return #dg>=3 and Duel.IsExists(true,s.atfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,dg)
	end
	local g=Duel.Select(HINTMSG_ATTACHTO,true,tp,s.atfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,dg)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,nil,3,tp,LOCATION_DECK,g)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local dg=Duel.GetDecktopGroup(tp,3):Filter(Card.IsCanBeAttachedTo,nil,tc,e,tp,REASON_EFFECT)
		if #dg>0 then
			Duel.DisableShuffleCheck(true)
			Duel.Attach(dg,tc,false,e,tp,REASON_EFFECT)
		end
	end
end

--E3
function s.xmatcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.xmatval(e)
	local d=Duel.GetAttackTarget()
	if d:IsSpecialSummoned() then
		return DOUBLE_DAMAGE
	else
		return 0
	end
end