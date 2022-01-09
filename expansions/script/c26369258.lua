--Psychostizia Incanalatore
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--pandemonium
	aux.AddOrigPandemoniumType(c)
	--activate
	local p1=Effect.CreateEffect(c)
	p1:GLString(0)
	p1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	p1:SetType(EFFECT_TYPE_QUICK_O)
	p1:SetCode(EVENT_FREE_CHAIN)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCondition(s.actcon)
	p1:SetTarget(s.acttg)
	p1:SetOperation(s.actop)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1,true,TYPE_PANDEMONIUM+TYPE_EFFECT,false,false,1,false,true)
	--set
	local p2=Effect.CreateEffect(c)
	p2:GLString(1)
	p2:SetType(EFFECT_TYPE_QUICK_O)
	p2:SetCode(EVENT_FREE_CHAIN)
	p2:SetRange(LOCATION_SZONE)
	p2:SetCountLimit(1)
	p2:SetCondition(aux.PandActCheck)
	p2:SetTarget(s.sttg)
	p2:SetOperation(s.stop)
	c:RegisterEffect(p2)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:GLString(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2x)
	--reveal
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:IsHasType(EFFECT_TYPE_ACTIVATE) and aux.PandActCheck(e) and s.acttg(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x2c2,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM,1750,1200,3,RACE_PSYCHO,ATTRIBUTE_LIGHT)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
	or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x2c2,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM,1750,1200,3,RACE_PSYCHO,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_PANDEMONIUM)
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end

function s.stfilter(c,tp)
	return c:IsSetCard(0x2c2) and c:IsType(TYPE_PANDEMONIUM) and aux.PandSSetCon(c,tp,true)() and not c:IsForbidden()
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,1601)
	local tc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		aux.PandSSet(tc,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
		Duel.ConfirmCards(1-tp,tc)
	end
end

function s.spfilter(c,e,tp)
	if c:IsLocation(LOCATION_EXTRA) then
		if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then
			return false
		end
	else
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
			return false
		end
	end
	return c:IsSetCard(0x2c2) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp) end
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_BATTLE==0
end	
function s.spfilter2(c,e,tp)
	if not c:IsFacedown() then return false end
	local check1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsSetCard(0x2c2) and c:IsType(TYPE_PANDEMONIUM) and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0x2c2,c:GetType(),c:GetTextAttack(),c:GetTextDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute())
	local check2=Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 and e:GetHandler():IsPandemoniumActivatable(tp,tp,true,false,false,false,eg,ep,ev,re,r,rp)
	return check1 or check2
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.spfilter2(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFacedown() then return end
	Duel.ConfirmCards(1-tp,Group.FromCards(tc))
	local check1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetCode(),0x2c2,tc:GetType(),tc:GetTextAttack(),tc:GetTextDefense(),tc:GetOriginalLevel(),tc:GetOriginalRace(),tc:GetOriginalAttribute())
	local check2=Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 and e:GetHandler():IsPandemoniumActivatable(tp,tp,true,false,false,false,eg,ep,ev,re,r,rp)
	if tc:IsSetCard(0x2c2) and tc:IsType(TYPE_PANDEMONIUM) then
		if not check1 then return end
		tc:AddMonsterAttribute(TYPE_EFFECT+TYPE_PANDEMONIUM)
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	elseif check2 and Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and e:GetHandler():IsRelateToEffect(e) then
		aux.PandAct(e:GetHandler())(e,tp,eg,ep,ev,re,r,rp)
		local te=e:GetHandler():GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=e:GetHandler():GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
	end
end