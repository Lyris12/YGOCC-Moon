--Sovrano Pulstar - Armatura Lanknoir
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tgcon)
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--atk boost
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
	local e4x=e4:Clone()
	e4x:SetCode(EVENT_REMOVE)
	e4x:SetCondition(s.atkcon2)
	c:RegisterEffect(e4x)
	--qe
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.target)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
end
function s.cf(c,lv)
	return c:IsFaceup() and c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:HasLevel() and c:GetLevel()<lv
end
function s.tgcon(e)
	return Duel.IsExistingMatchingCard(s.cf,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler(),e:GetHandler():GetLevel())
end

function s.filter(c,tp,loc)
	return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsPreviousControler(tp) and c:IsPreviousLocation(loc) and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp,LOCATION_HAND)
end
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp,LOCATION_GRAVE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() then return end
	Duel.Hint(HINT_CARD,tp,id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
end

function s.thfilter(c,ft,e,tp)
	local ec=e:GetHandler()
	return c:IsMonster() and c:IsSetCard(0x4) and c:IsAttribute(ec:GetAttribute()) and c:HasLevel() and c:GetLevel()<ec:GetLevel()
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return c:IsAttackAbove(2000) and c:IsDefenseAbove(2000) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,ft,e,tp)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0,-2000)
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,e:GetHandler(),1,0,0,-2000)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsAttackAbove(2000) and c:IsDefenseAbove(2000) then
		local _,atk=c:UpdateATK(-2000,true)
		local _,def=c:UpdateDEF(-2000,true)
		if atk==def and atk==-2000 then
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,ft,e,tp):GetFirst()
			if not sc then return end
			aux.ToHandOrElse(sc,tp,
				function(sc)
					return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				end,
				function(sc)
					return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				end,
				aux.Stringid(id,2))
		end
	end
end