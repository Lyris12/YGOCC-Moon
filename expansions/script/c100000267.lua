--[[
Sceluspecter Doomed Bastille
Scelleraspettro Bastiglia Condannata
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:Activation(true)
	--[[Once per turn: You can discard 1 DARK monster; draw 1 card and reveal it, then, if it is not a DARK monster, banish 1 card from your GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DRAW|CATEGORY_REMOVE|CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:OPT()
	e1:SetFunctions(
		nil,
		aux.DiscardCost(aux.MonsterFilter(Card.IsAttribute,ATTRIBUTE_DARK)),
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[If you would Xyz Summon a "Number" monster with a number between "201" and "214" in its name, you can also use monsters your opponent controls with "Sceluspecter" monsters equipped to them,
	as materials.]]
	aux.EnableXyzLevelFreeMods=true
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_XYZ_MATERIAL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.xmattg)
	e2:SetValue(s.xmatval)
	c:RegisterEffect(e2)
	--[[If you would Xyz Summon "Number 201: Sceluspecter Phantom Magician" while there are 3 or more "Sceluspecter" Monster Cards that are currently equipped to monsters your opponent controls,
	you can treat all of the materials as Level 7, even if they do not have Levels.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_XYZ_LEVEL)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e3:SetCondition(s.xlvcon)
	e3:SetValue(s.xlvval)
	c:RegisterEffect(e3)
end

--E1
function s.filter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.publicfilter(c,convulsion,top_card)
	return (c:IsPublic() or (convulsion and c==top_card)) and not s.filter(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExists(false,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil) end
	local top_card=Duel.GetDecktopGroup(tp,1):GetFirst()
	local convulsion=Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_DECK)
	local dg=Duel.GetMatchingGroup(s.publicfilter,tp,LOCATION_DECK,0,nil,convulsion,top_card)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetConditionalOperationInfo(#dg>0,0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local dr=Duel.GetOperatedGroup():GetFirst()
	Duel.ConfirmCards(1-tp,dr)
	if not s.filter(dr) then
		local g=Duel.Select(HINTMSG_REMOVE,false,tp,aux.Necro(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.BreakEffect()
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end

--E2
function s.eqcfilter(c)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsSetCard(ARCHE_SCELUSPECTER)
end
function s.xmattg(e,c)
	local g=c:GetEquipGroup()
	return g and g:IsExists(s.eqcfilter,1,nil)
end
function s.xmatval(e,c,xyzc,tp)
	if not (tp==e:GetHandlerPlayer() and xyzc:IsSetCard(ARCHE_NUMBER)) then return false end
	local n=aux.GetXyzNumber(xyzc)
	return n>=201 and n<=214
end

--E3
function s.xlvcfilter(c,p)
	if not s.eqcfilter(c) then return false end
	local ec=c:GetEquipTarget()
	return ec and ec:IsControler(p)
end
function s.xlvcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExists(false,s.xlvcfilter,tp,LOCATION_SZONE,LOCATION_SZONE,3,nil,1-tp)
end
function s.xlvval(e,c,xyzc)
	if not (xyzc:IsCode(CARD_NUMBER_201) and xyzc:IsControler(e:GetHandlerPlayer())) then return c:GetLevel() end
	if c:HasLevel() then
		return (7<<16)|c:GetLevel()
	else
		return 7
	end
end