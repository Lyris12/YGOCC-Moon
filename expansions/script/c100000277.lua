--[[
Number i208: Sceluspecter Phantom Hands
Numero i208: Scelleraspettro Mani dello Spirito
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 Level 2 DARK monsters
	aux.EnableXyzMods=true
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),2,2,s.altmat,aux.Stringid(id,0))
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ALLOW_EXTRA_XYZ_MATERIAL)
	e0:SetValue(s.altmatval)
	c:RegisterEffect(e0)
	--[[If this card is Xyz Summoned: Banish all monsters on the field that have "Sceluspecter" Monster Cards equipped to them, and if you do,
	attach as many "Sceluspecter" monsters from your GY to this card as possible.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[(Quick Effect): You can detach 1 material from this card, then target 1 monster your opponent controls; equip 1 "Sceluspecter" monster from your hand, Deck, or GY to that target.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		nil,
		s.eqcost,
		s.eqtg,
		s.eqop
	)
	c:RegisterEffect(e2)
end
aux.xyz_number[id]=208

function s.altmat(c,e,tp,xyzc)
	local g=c:GetEquipGroup()
	return c:IsFaceup() and c:IsXyzType(TYPE_MONSTER) and g and g:IsExists(s.eqcfilter,1,nil)
end
function s.altmatval(e,c,xyzc,tp)
	if not aux.IsUsingAlternativeXyzProcedure then return false end
	local g=c:GetEquipGroup()
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and s.altmat(c,e,tp,xyzc)
end
function s.eqcfilter(c)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsSetCard(ARCHE_SCELUSPECTER)
end

--E1
function s.rmfilter(c)
	local g=c:GetEquipGroup()
	return c:IsFaceup() and g and g:IsExists(s.eqcfilter,1,nil) and c:IsAbleToRemove()
end
function s.ovfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsCanOverlay()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local rg=Duel.Group(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ag=Duel.Group(s.ovfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.SetCardOperationInfo(rg,CATEGORY_REMOVE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,ag,#ag,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.Group(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
		local ag=Duel.Group(s.ovfilter,tp,LOCATION_GRAVE,0,nil)
		if #ag==0 then return end
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:IsType(TYPE_XYZ) then
			Duel.Attach(ag,c)
		end
	end
end

--E2
function s.eqtofilter_base(c,e,tp)
	return c:IsCanBeEquippedWith(nil,e,tp,REASON_EFFECT) and c:IsCanBeEffectTarget(e)
end
function s.eqtofilter(c,e,tp)
	return Duel.IsExists(false,s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,c,c,e,tp)
end
function s.eqfilter(c,ec,e,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and ec:IsCanBeEquippedWith(c,e,tp,REASON_EFFECT)
end
function s.eqfilter_alt(c,e,tp)
	local loc=c:DestinationRedirect(LOCATION_GRAVE,REASON_COST)
	if loc==0 then
		loc=LOCATION_GRAVE
	end
	if loc&(LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)==0 or not c:IsAbleToLocationAsCost(loc) then return false end
	c:SetLocationAfterCost(loc)
	local res=c:IsOriginalType(TYPE_MONSTER) and c:IsSetCard(ARCHE_SCELUSPECTER) and Duel.IsExists(true,Card.IsCanBeEquippedWith,tp,0,LOCATION_MZONE,1,nil,c,e,tp,REASON_EFFECT)
	c:SetLocationAfterCost(0)
	return res
end
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ThereAreValidEquips=Duel.IsExists(true,s.eqtofilter,tp,0,LOCATION_MZONE,1,nil,e,tp)
	if chk==0 then
		local g=Duel.Group(s.eqtofilter_base,tp,0,LOCATION_MZONE,nil,e,tp)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or #g==0 then return false end
		if ThereAreValidEquips then
			return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
		else
			local og=c:GetOverlayGroup()
			return og:IsExists(s.eqfilter_alt,1,nil,c,e,tp)
		end
	end
	if ThereAreValidEquips then
		c:RemoveOverlayCard(tp,1,1,REASON_COST)
	else
		local og=c:GetOverlayGroup()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
		local tc=og:FilterSelect(tp,s.eqfilter_alt,1,1,nil,e,tp):GetFirst()
		Duel.SendtoGrave(tc,REASON_COST)
		Duel.RaiseSingleEvent(tc,EVENT_DETACH_MATERIAL,e,REASON_COST,tp,0,0)
	end
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.eqtofilter(chkc,e,tp) end
	if chk==0 then
		return e:IsCostChecked() or (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExists(true,s.eqtofilter,tp,0,LOCATION_MZONE,1,nil,e,tp))
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.eqtofilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_EQUIP)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsCanBeEquippedWith(nil,e,tp,REASON_EFFECT) then
		local ec=Duel.Select(HINTMSG_EQUIP,false,tp,aux.Necro(s.eqfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tc,e,tp):GetFirst()
		if ec then
			Duel.EquipToOtherCardAndRegisterLimit(e,tp,ec,tc,true)
		end
	end
end