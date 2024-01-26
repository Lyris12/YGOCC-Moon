--[[
Forged Skyshard - Relentless Grit
Cieloframmento Forgiato - Grinta Tenace
Card Author: Kinny
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id-1)
	--Activation
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	--The equipped monster gains 300 ATK/DEF, and its Attribute is also treated as DARK.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	e3:UpdateDefenseClone(c)
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_EQUIP)
	e3x:SetCode(EFFECT_ADD_ATTRIBUTE)
	e3x:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e3x)
	--[[If you Bigbang Summon a Bigbang Monster, you can also use this card as a monster for its Bigbang Summon, with ATK/DEF equal to the equipped monster's ATK/DEF.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_EXTRA_BIGBANG_MATERIAL)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.matcon)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:Desc(1)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
	e5:SetCode(EFFECT_MATERIAL_CUSTOM_BIGBANG_STATS)
	e5:SetLabel(1)
	e5:SetLabelObject(c)
	e5:SetTarget(s.matcustomtg)
	e5:SetValue(s.matcustomval)
	e5:SetOperation(s.matop)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_EXTRA,LOCATION_EXTRA)
	e6:SetCondition(s.efcon)
	e6:SetTarget(s.eftg)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
	--[[If this card is sent to the GY: You can target 1 "Skyvoid Ranger, Espada" that is in your GY or banished; Special Summon it.]]
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:HOPT()
	e7:SetTarget(s.sptg)
	e7:SetOperation(s.spop)
	c:RegisterEffect(e7)
end
--E1
function s.filter(c,e,tp)
	if not c:IsFaceup() then return false end
	return c:IsType(TYPE_BIGBANG) or Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE|LOCATION_GRAVE,0,1,e:GetHandler())
end
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSpell(TYPE_EQUIP) and (c:IsLocation(LOCATION_GRAVE) or c:GetSequence()<5)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end

--E2
function s.eqlimit(e,c)
	return c:IsType(TYPE_BIGBANG) or Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_SZONE|LOCATION_GRAVE,0,1,e:GetHandler())
end

--E4
function s.matcon(e,mc,tp,bc,chk)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and not Duel.PlayerHasFlagEffect(tp,id)
end

--E5
function s.matcustomtg(e,c,bc,mg,tp)
	local ec=c:GetEquipTarget()
	return ec and ec:HasAttack() and ec:HasDefense() and c==e:GetLabelObject() and tp==e:GetHandlerPlayer()
end
function s.matcustomval(e,c,bc,mg,tp)
	local ec=c:GetEquipTarget()
	return ec:GetAttack(),ec:GetDefense()
end
function s.matop(e,mc,tp,dg)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end

--E6
function s.efcon(e)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	return ec and not Duel.PlayerHasFlagEffect(e:GetHandlerPlayer(),id)
end
function s.eftg(e,c)
	return c:IsType(TYPE_BIGBANG)
end

--E7
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(id-1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return ((chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE)) or chkc:IsLocation(LOCATION_REMOVED)) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end