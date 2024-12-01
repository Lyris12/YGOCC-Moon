--[[
CODED LAND - Future City
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--maintain
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:OPT()
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
--E1
function s.filter(c)
	return c:IsSetCard(ARCHE_CODE_JAKE) and c:IsType(TYPE_SPELL|TYPE_TRAP) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.Search(sg)
	end
end

--E2
function s.spfilter(c,e,tp,lv)
	return c:IsSetCard(ARCHE_CODED_EYES) and c:HasLevel() and not c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.addfilter(c,lv)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(ARCHE_CODEMAN) and c:HasLevel() and not c:IsLevel(lv) and c:IsAbleToHand()
end
function s.tgfilter(c,e,tp,ftchk)
	if not c:IsFaceup() or not c:IsSetCard(ARCHE_CODE_JAKE) or c:IsAttack(c:GetBaseAttack()) or not c:HasLevel() then return false end
	local a=ftchk and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp,c:GetLevel())
	local b=Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,c,c:GetLevel())
	return a or b
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if not chkc:IsLocation(LOCATION_MZONE) or not chkc:IsControler(tp) or not chkc:IsFaceup() or not chkc:IsSetCard(ARCHE_CODE_JAKE) or chkc:IsAttack(chkc:GetBaseAttack()) or not chkc:HasLevel() then return false end
		local opt=Duel.GetChainInfo(e:GetChainLink(),CHAININFO_TARGET_PARAM)
		if opt==1 then
			return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,chkc,e,tp,chkc:GetLevel())
		elseif opt==2 then
			return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,chkc,chkc:GetLevel())
		end
	end
	local ftchk=Duel.GetMZoneCount(tp)>0
	if chk==0 then
		return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ftchk)
	end
	e:SetCategory(0)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ftchk):GetFirst()
	if not tc then return end
	local a=ftchk and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,tc,e,tp,tc:GetLevel())
	local b=Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,tc,tc:GetLevel())
	local opt=aux.Option(tp,id,1,a,b)
	if opt then
		opt=opt+1
	else
		return
	end
	Duel.SetTargetParam(opt)
	if opt==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif opt==2 then
		e:SetCategory(CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or not tc:IsControler(tp) or not tc:IsFaceup() or not tc:IsSetCard(ARCHE_CODE_JAKE) or tc:IsAttack(tc:GetBaseAttack()) or not tc:HasLevel() then return end
	local opt=Duel.GetTargetParam()
	if opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetLevel())
		if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel())
		if #g>0 then Duel.Search(g) end
	end
end