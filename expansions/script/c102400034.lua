--created & coded by Lyris, art at https://www.1e.com/wp-content/uploads/2017/03/tachyon-pop-culture-energy.png
--フォトンシック・タキオン
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.hcon)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and rp==1-tp
end
function s.cfilter(c)
	return c:IsFacedown() and c:IsRank(8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE)
		or Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()))
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
		Duel.BreakEffect()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	e:SetLabelObject(tc)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(e:GetLabelObject())
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.sfilter(c,e,tp,mc)
	return mc:IsCanBeXyzMaterial(c)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mc=re:GetHandler()
	if not (Duel.NegateActivation(ev) and mc:IsRelateToEffect(re)
		and aux.MustMaterialCheck(mc,tp,EFFECT_MUST_BE_XMATERIAL)) or mc:IsImmuneToEffect(e) then return end
	local sc=Duel.GetFirstTarget()
	if sc and sc:IsRelateToEffect(e) and mc:IsCanBeXyzMaterial(nil,tp,REASON_EFFECT) and sc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mg,sc)>0 and Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		local mg=mc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(mc))
		Duel.Overlay(sc,Group.FromCards(mc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
function s.xfilter(c)
	return c:IsFacedown() or not (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsRace(RACE_DRAGON))
end
function s.hcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandler():GetControler()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.xfilter,tp,LOCATION_MZONE,0,1,nil)
end
