--[[
CODEMAN: Acceller
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--level change
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:HOPT()
	e2:SetTarget(s.lvtar)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	--spsummon2
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e3:HOPT()
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
--E1
function s.atkcheck(c)
	return not c:IsAttack(c:GetBaseAttack())
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,nil)
	return #g>=2 and g:IsExists(s.atkcheck,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end

--E2
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsSetCard(ARCHE_CODEMAN)
end
function s.lvtar(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsLevelAbove(1) and Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local val=math.max(1,math.abs(c:GetLevel()-tc:GetLevel()))
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,0,val*100)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler() 
	if c:IsFaceup() and c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsLevelBelow(4) and tc:IsSetCard(ARCHE_CODEMAN) and tc:IsControler(tp) then
		local e1,diff=c:UpdateLevel(-tc:GetLevel(),true,c)
		if not c:IsImmuneToEffect(e1) and diff<=0 then
			tc:UpdateATK(c:GetLevel()*100,true,{c,true})
		end
	end
end

--E3
function s.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_CODEMAN) and c:IsLevelAbove(1)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel())
end
function s.spfilter(c,e,tp,lv)
	return c:IsMonster() and c:IsSetCard(ARCHE_CODE_JAKE) and c:IsLevelBelow(lv)
		and (c:IsAbleToHand() or (ftcheck and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)))
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ftcheck=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,e,tp,ftcheck) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ftcheck) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ftcheck)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:HasLevel() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetLevel(),Duel.GetLocationCount(tp,LOCATION_MZONE)>0):GetFirst()
		if sc then
			Duel.ToHandOrSpecialSummon(sc,e,tp,nil,0,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
