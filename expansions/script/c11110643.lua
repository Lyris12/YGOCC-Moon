--Envoy of the Sword Graveyard
--Inviato del Cimitero di Spade
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,aux.NOT(Card.IsNeutral),2,2)
	--[[If this card is Bigbang Summoned: You can target 1 Equip Spell or Union Monster in your GY; equip it to an appropriate monster you control.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.BigbangSummonedCond)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--[[If this card is destroyed as Bigbang Material: You can add 1 Union Monster from your Deck to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetTarget(aux.SearchTarget(s.filter))
	e2:SetOperation(aux.SearchOperation(s.filter))
	c:RegisterEffect(e2)
end
--FILTERS E1
function s.eqfilter(c,tp)
	if c:IsForbidden() or not c:CheckUniqueOnField(tp) then return false end
	if c:IsSpell(TYPE_EQUIP) then
		return Duel.IsExists(false,s.eqcfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_EQUIP,c)
	elseif c:IsMonster(TYPE_UNION) then
		return Duel.IsExists(false,s.eqcfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_UNION,c)
	end
	return false
end
function s.eqcfilter(c,typ,ec)
	if not c:IsFaceup() then return false end
	if typ==TYPE_EQUIP then
		return ec:CheckEquipTarget(c)
	elseif typ==TYPE_UNION then
		return ec:CheckUnionTarget(c) and aux.CheckUnionEquip(ec,c)
	end
	return false
end
--E1
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsInGY() and chkc:IsControler(tp) and s.eqfilter(chkc,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local ec=Duel.GetFirstTarget()
	if ec and ec:IsRelateToChain() then 
		local type = ec:IsSpell(TYPE_EQUIP) and TYPE_EQUIP or ec:IsMonster(TYPE_UNION) and TYPE_UNION or 0
		if type==0 then return end
		local g=Duel.Select(HINTMSG_FACEUP,false,tp,s.eqcfilter,tp,LOCATION_MZONE,0,1,1,nil,type,ec)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			if Duel.Equip(tp,ec,tc) and type==TYPE_UNION then
				aux.SetUnionState(ec)
			end
		end
	end
end

--FE2
function s.filter(c)
	return c:IsMonster(TYPE_UNION)
end
--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetReason()&(REASON_MATERIAL|REASON_BIGBANG)==REASON_MATERIAL|REASON_BIGBANG
end