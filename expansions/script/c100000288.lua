--[[
Dynastygian Guard - "Shield"
Guardia Dinastigiana - "Scudo"
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Your opponent's monsters cannot target for attacks, and your opponent cannot target or destroy with card effects, any "Dynastygian" monsters you control,
	except "Dynastygian Guard - "Shield"".]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.limval)
	c:RegisterEffect(e1)
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_FIELD)
	e1x:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1x:SetTargetRange(LOCATION_MZONE,0)
	e1x:SetRange(LOCATION_MZONE)
	e1x:SetTarget(s.limval)
	e1x:SetValue(aux.indoval)
	c:RegisterEffect(e1x)
	local e1y=Effect.CreateEffect(c)
	e1y:SetType(EFFECT_TYPE_FIELD)
	e1y:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1y:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1y:SetRange(LOCATION_MZONE)
	e1y:SetTargetRange(LOCATION_MZONE,0)
	e1y:SetTarget(s.limval)
	e1y:SetValue(aux.tgoval)
	c:RegisterEffect(e1y)
	--[[If this card is Normal or Special Summoned, or if another "Dynastygian" monster(s) is Special Summoned to your field:
	You can add 1 "Dynastygian" Spell/Trap from your Deck or GY to your hand.]]
	local sptg=xgl.SearchTarget(s.thfilter,LOCATION_DECK|LOCATION_GRAVE)
	local spop=xgl.SearchOperation(s.thfilter,LOCATION_DECK|LOCATION_GRAVE)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		nil,
		sptg,
		spop
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,0)
	e3:SetCategory(CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SHOPT()
	e3:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e3:SetFunctions(
		aux.AlreadyInRangeEventCondition(s.spcfilter),
		nil,
		sptg,
		spop
	)
	c:RegisterEffect(e3)
	--[[During your Main Phase: You can target 1 Level 4 or lower "Dynastygian" monster in your GY or banishment, except "Dynastygian Guard - "Shield"";
	add that target to your hand, or if your opponent controls more cards than you do, you can Special Summon that target, instead.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,1)
	e4:SetCategory(CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetFunctions(
		nil,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e4)
end
--E1
function s.limval(e,c)
	return not c:IsCode(id) and c:IsSetCard(ARCHE_DYNASTYGIAN)
end

--E2
function s.thfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_DYNASTYGIAN)
end

--E3
function s.spcfilter(c,_,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(ARCHE_DYNASTYGIAN)
end

--E4
function s.thfilter2(c,check,e,tp)
	return c:IsFaceupEx() and c:IsMonster() and c:IsLevel(4) and c:IsSetCard(ARCHE_DYNASTYGIAN) and not c:IsCode(id)
		and (c:IsAbleToHand() or (check and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local check=Duel.GetMZoneCount(tp)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(tp) and s.thfilter2(chkc,check,e,tp) end
	if chk==0 then
		return Duel.IsExists(true,s.thfilter2,tp,LOCATION_GB,0,1,nil,check,e,tp)
	end
	local tc=Duel.Select(HINTMSG_TARGET,true,tp,s.thfilter2,tp,LOCATION_GB,0,1,1,nil,check,e,tp):GetFirst()
	local b1=tc:IsAbleToHand()
	local b2=check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	if b1 and b2 then 
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	elseif b1 then
		Duel.SetCardOperationInfo(tc,CATEGORY_TOHAND)
	else
		Duel.SetCardOperationInfo(tc,CATEGORY_SPECIAL_SUMMON)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceupEx() and tc:IsMonster() and tc:IsLevel(4) and tc:IsSetCard(ARCHE_DYNASTYGIAN) and not tc:IsCode(id) then
		local check=Duel.GetMZoneCount(tp)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		Duel.ToHandOrSpecialSummon(tc,e,tp,check)
	end
end