--Tungsten, Demimetalurgos Driver
--Tungsteno, Demimetalurgo Driver
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,Card.IsNeutral,2,2,s.matgroup)
	--[[This card gains 700 ATK/DEF for each face-up card in your Spell & Trap Zone.]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.adval)
	c:RegisterEffect(e0)
	e0:UpdateDefenseClone(c)
	--[[While you have an Engaged "Metalurgos" Drive Monster, "Metalurgos" Continuous Spells you control cannot be destroyed by your opponent's card effects.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetCondition(aux.IsExistingEngagedCond(0,s.enfilter))
	e1:SetTarget(s.imtg)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--[[During the Main Phase (Quick Effect): You can add 1 "Metalurgos" Drive Monster from your Deck or GY to your hand,
	and if you do, you can Engage it, and if you do that, reduce its Energy to 1.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetCustomCategory(CATEGORY_CHANGE_ENERGY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetHintTiming(0,RELEVANT_TIMINGS)
	e2:SetCondition(aux.MainPhaseCond())
	e2:SetTarget(s.sctg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)	
end
function s.matfilter(c)
	return (c:IsMonster() or c:IsLocation(LOCATION_MZONE)) and c:IsSetCard(ARCHE_METALURGOS) and not c:IsCode(id)
end
function s.matgroup(g,c,tp)
	return g:IsExists(s.matfilter,1,nil)
end

--E0
function s.adval(e,c)
	local tp=c:GetControler()
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsInBackrow),tp,LOCATION_SZONE,0,nil)*700
end

--E1
function s.enfilter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsSetCard(ARCHE_METALURGOS)
end
function s.imtg(e,c)
	return c:IsSpell(TYPE_CONTINUOUS) and c:IsSetCard(ARCHE_METALURGOS)
end

--FILTERS E2
function s.thfilter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsSetCard(ARCHE_METALURGOS) and c:IsAbleToHand()
end
--E2
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleCustomOperationInfo(0,CATEGORY_CHANGE_ENERGY,nil,1,0,1)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SearchAndEngage(tc,e,tp) and tc:IsCanChangeEnergy(1,tp,REASON_EFFECT,e) then
			tc:ChangeEnergy(1,tp,REASON_EFFECT,true,e:GetHandler())
		end
	end
end