--Gelatyna Inceppante
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(aux.LabelCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_ST) and Duel.IsChainNegatable(ev)
end
function s.cfilter(c)
	return c:GetDefense()==200 and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.cf(c,e,tp)
	return c:IsMonster() and c:IsSetCard(0x296) and c:IsDestructable(e,REASON_COST,tp) and Duel.GetMZoneCount(tp,c)>0 and c:HasLevel()
		and Duel.IsExists(false,s.spf,tp,LOCATION_DECK,0,1,c,e,tp,c:GetLevel())
end
function s.spf(c,e,tp,lv)
	return c:IsMonster() and c:IsSetCard(0x296) and c:HasLevel() and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local relation=rc:IsRelateToEffect(re)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cf,tp,LOCATION_HAND,0,1,nil,e,tp) and (rc:IsAbleToRemove(tp) or not relation and Duel.IsPlayerCanRemove(tp))
	end
	e:SetLabel(0)
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,s.cf,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 and Duel.Destroy(g,REASON_COST)>0 and g:GetFirst():IsMonster() and g:GetFirst():IsSetCard(0x296) then
		Duel.SetTargetParam(g:GetFirst():GetLevel())
	else
		return
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	if relation then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,0,rc:GetPreviousLocation())
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)>0 and eg:GetFirst():IsBanished() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local lv=Duel.GetTargetParam()
		if not lv then return end
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spf,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
