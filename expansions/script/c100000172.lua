--[[
Muscwole Stormcold
Muscolosso Tempestafredda
Card Author: LeonDuvall
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If you control no monsters, or if your opponent controls a monster, you can Special Summon this card (from your hand).]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--[[Cannot be targeted by the effects of Equip Cards, except "Muscwole" cards.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--[[● 2400+: You can send 1 "Muscwole" card from your hand or Deck to the GY; Set 1 "Muscwole Murdermania" from your Deck or GY to your field.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(s.atkcon(2400),s.setcost,s.settg,s.setop)
	c:RegisterEffect(e3)
	--[[● 3100+: You can return 1 banished "Muscwole" card to the GY; Special Summon 1 "Muscwole" monster from your hand or GY.]]
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetFunctions(s.atkcon(3100),s.spcost,s.sptg,s.spop)
	c:RegisterEffect(e4)
	--[[● 3800+: If a "Muscwole" monster you control attacks a Defense Position monster, inflict piercing battle damage to your opponent.]]
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_PIERCE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(s.atkcon(3800))
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_MUSCWOLE))
	c:RegisterEffect(e5)
end
function s.atkcon(val)
	return	function(e)
				return e:GetHandler():IsAttackAbove(val)
			end
end

--E1
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0)
end

--E2
function s.efilter(e,re,rp)
	return re:IsActiveType(TYPE_EQUIP) and not re:GetHandler():IsSetCard(ARCHE_MUSCWOLE,true)
end

--E3
function s.tgfilter(c,tp)
	if not (c:IsSetCard(ARCHE_MUSCWOLE) and c:IsAbleToGraveAsCost()) then return false end
	c:SetLocationAfterCost(LOCATION_GRAVE)
	local res = (c:IsOwner(tp) and s.setfilter(c)) or Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	c:SetLocationAfterCost(0)
	return res
end
function s.setfilter(c)
	return c:IsCode(CARD_MUSCWOLE_MURDERMANIA) and c:IsST() and c:IsSSetable()
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end

--E4
function s.rtfilter(c,e,tp)
	if not (c:IsFaceup() and c:IsSetCard(ARCHE_MUSCWOLE)) then return false end
	c:SetLocationAfterCost(LOCATION_GRAVE)
	local res = (c:IsOwner(tp) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	c:SetLocationAfterCost(0)
	return res
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_MUSCWOLE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp)
	end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.rtfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoGrave(g,REASON_COST|REASON_RETURN)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and (e:IsCostChecked() or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp))
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end