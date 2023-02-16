--Visitor from the Deptheavens
local ref,id=GetID()
Duel.LoadScript("Deptheaven.lua")
function ref.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	Deptheaven.AddPendRestrict(c)
	--Summon S/T
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(ref.ssptg)
	e1:SetOperation(ref.sspop)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(ref.sscost)
	e2:SetTarget(ref.sstg)
	e2:SetOperation(ref.ssop)
	c:RegisterEffect(e2)
	--GY Scale (Draw)
	local e3=Deptheaven.EnableGYScale(c,ref.drtg,ref.drop)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
end

--Summon S/T
function ref.sspfilter(c,e,tp)
	if c:IsLocation(LOCATION_MZONE) or not (Deptheaven.Is(c) and c:IsType(TYPE_SPELL+TYPE_TRAP)) then return false end
	if bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	else return Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),Deptheaven.Code,TYPE_NORMAL,0,0,4,0,0) end
end
function ref.ssptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(ref.sspfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,ref.sspfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function ref.sspop(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return false end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local res=0
		if bit.band(tc:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER then res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			tc:AddMonsterAttribute(TYPE_NORMAL,0,0,4,0,0)
			res=Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end

--Special Summon
function ref.sscfilter(c,ft) return c:IsAbleToGraveAsCost() and (ft>0 or (c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5)) end
function ref.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.sscfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,ft)
	Duel.SendtoGrave(g,REASON_COST)
end
function ref.ssfilter(c,e,tp) return Deptheaven.Is(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end

--Draw
function ref.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function ref.drop(e,tp,eg,ep,ev,re,r,rp) Duel.Draw(tp,1,REASON_EFFECT) end
