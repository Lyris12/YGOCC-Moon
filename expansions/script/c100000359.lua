--[[
Vacuous Monarch
Monarca Vacuo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_VACUOUS_VASSAL,CARD_POWER_VACUUM_ZONE,CARD_POWER_VACUUM_BLADE)
	--[[If this card is in your hand or GY: You can banish 2 Level 5 or lower "Vacuous" monsters from your field and/or GY, including 1 "Vacuous Vassal"; Special Summon this card, and if you do, add 1
	"Power Vacuum Blade" from your Deck or GY to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		s.spcost,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[Up to thrice per turn: You can target 1 monster your opponent controls with 0 ATK or DEF; if only its ATK or DEF is 0, negate its effects, otherwise banish it face-down. This is a Quick Effect
	if you control "Power Vacuum Zone".]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DISABLE|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(3)
	e2:SetFunctions(
		nil,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e2)
	e2:QuickEffectClone(c,aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),LOCATION_ONFIELD,0,1))
	--[[While this card is equipped with "Power Vacuum Blade", it can make up to 3 attacks on monsters during each Battle Phase.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(2)
	c:RegisterEffect(e3)
end
--E1
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsMonster() and c:IsSetCard(ARCHE_VACUOUS) and c:IsLevelBelow(5) and c:IsAbleToRemoveAsCost()
end
function s.gcheck(g,e,tp,mg,c)
	return g:IsExists(Card.IsCode,1,nil,CARD_VACUOUS_VASSAL) and Duel.GetMZoneCount(tp,g)>0
end
function s.thfilter(c)
	return c:IsCode(CARD_POWER_VACUUM_BLADE) and c:IsAbleToHand()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,c)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,0)
	end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,1,tp,HINTMSG_REMOVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_COST)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExists(false,s.thfilter,tp,LOCATION_GRAVE|LOCATION_DECK,0,1,c)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_GRAVE|LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.Search(g)
		end
	end
end

--E2
function s.filter(c,tp)
	if not c:IsFaceup() then return false end
	local ct=0
	if c:IsAttack(0) then ct=ct+1 end
	if c:IsDefense(0) then ct=ct+1 end
	if ct==0 then
		return false
	elseif ct==1 then
		return aux.NegateMonsterFilter(c)
	else
		return c:IsAbleToRemove(tp,POS_FACEDOWN)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc,tp) end
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,0,LOCATION_MZONE,1,nil,tp)
	end
	local tc=Duel.Select(HINTMSG_FACEUP,true,tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst()
	local cond=tc:IsAttack(0) and tc:IsDefense(0)
	Duel.SetConditionalOperationInfo(not cond,0,CATEGORY_DISABLE,tc,1,0,0)
	Duel.SetConditionalOperationInfo(cond,0,CATEGORY_REMOVE,tc,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or not tc:IsFaceup() then return end
	local ct=0
	if tc:IsAttack(0) then ct=ct+1 end
	if tc:IsDefense(0) then ct=ct+1 end
	if ct==0 then
		return
	elseif ct==1 and tc:IsCanBeDisabledByEffect(e) then
		Duel.NegateMonster(tc,e)
	elseif ct==2 then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end

--E3
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipGroup():IsExists(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_BLADE),1,nil)
end