--[[
Draining Prison of Eight Blades
Prigione Prosciugante delle Otto Lame
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_BLADE)
	--You can only control 1 "Draining Prison of Eight Blades".
	c:SetUniqueOnField(1,0,id)
	--[[When this card is activated: Send up to 3 "Sceluspecter" monsters from your hand and/or Deck to the GY, and if you do,
	negate the effects of face-up cards your opponent controls, up to the number of "Sceluspecter" monsters sent to the GY.]]
	local e0=c:Activation(true,true,nil,nil,s.target,s.activate,true)
	e0:SetDescription(id,0)
	e0:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DISABLE)
	c:RegisterEffect(e0)
	--[[Monsters your opponent controls that have "Sceluspecter" Monster Cards equipped to them cannot attack, be Tributed, or used as Fusion, Synchro, or Link Materials.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.fieldtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_FIELD)
	e2x:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2x:SetRange(LOCATION_SZONE)
	e2x:SetCode(EFFECT_CANNOT_RELEASE)
	e2x:SetTargetRange(0,1)
	e2x:SetTarget(aux.PlayerCannotTributeTarget(0,LOCATION_MZONE,s.fieldtg))
	c:RegisterEffect(e2x)
	aux.FieldCannotBeTributeOrMaterial(c,LOCATION_SZONE,0,LOCATION_MZONE,s.fieldtg,TYPE_NORMAL|TYPE_XYZ)
	--[[Once per turn: You can Tribute 1 "Sceluspecter" monster you control, or 1 monster on either field with a "Sceluspecter" monster equipped to it; place 1 Blade Counter on this card.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:OPT()
	e3:SetRelevantTimings()
	e3:SetFunctions(
		nil,
		aux.TributeGlitchyCost(s.cfilter,1,1,nil,false,true,s.exfilter,0,LOCATION_MZONE,nil,nil,nil),
		s.cttg,
		s.ctop
	)
	c:RegisterEffect(e3)
	--All face-up DARK Xyz Monsters you control gain 800 ATK/DEF for each Blade Counter on this card.
	c:UpdateATKDEFField(s.statval,nil,LOCATION_SZONE,LOCATION_MZONE,0,s.stattg)
end
--E1
function s.filter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsAbleToGrave()
end
function s.checkfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER)
end
function s.disfilter(c,e)
	return aux.NegateAnyFilter(c) and c:IsCanBeDisabledByEffect(e,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return Duel.IsExists(false,s.filter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.filter,tp,LOCATION_HAND|LOCATION_DECK,0,1,3,nil)
	if #tg>0 and Duel.SendtoGrave(tg,REASON_EFFECT)>0 then
		local ct=Duel.GetOperatedGroup():FilterCount(s.checkfilter,nil)
		if ct>0 then
			local g=Duel.Select(HINTMSG_DISABLE,false,tp,s.disfilter,tp,0,LOCATION_ONFIELD,1,ct,nil,e)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.Negate(g,e,0,false,false,TYPE_NEGATE_ALL)
			end
		end
	end
end

--E2
function s.fieldtg(e,c)
	local g=c:GetEquipGroup()
	return g and g:IsExists(s.eqcfilter,1,nil)
end
function s.eqcfilter(c)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsSetCard(ARCHE_SCELUSPECTER)
end

--E3
function s.cfilter(c,e,tp)
	return (c:IsControler(tp) and c:IsSetCard(ARCHE_SCELUSPECTER)) or s.fieldtg(nil,c)
end
function s.exfilter(c,e,tp)
	return s.fieldtg(nil,c)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(COUNTER_BLADE,1) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,COUNTER_BLADE)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsCanAddCounter(COUNTER_BLADE,1) then
		c:AddCounter(COUNTER_BLADE,1)
	end
end

--E4
function s.statval(e,c)
	return e:GetHandler():GetCounter(COUNTER_BLADE)*800
end
function s.stattg(e,c)
	return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
end