--[[
Zerost End
Fine Zerost
Card Author: TopHatPenguin
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--[[Each time a "Zerost" card(s) is banished: All monsters your opponent currently controls lose 100 ATK/DEF.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_ATKDEF)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--[[If you Fusion Summon a Fusion Monster, you can also banish 1 "Zerost" monster from your GY as material.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	e2:HOPT()
	e2:SetTarget(s.fustg)
	e2:SetValue(s.fusval)
	e2:SetOperation(s.fusop)
	c:RegisterEffect(e2)
	--[[If a "Zerost" card(s) leaves your banishment: You can send 1 "Zerost" card from your Deck to the GY with a different original name from among those cards.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_MOVE,s.cfilter,id,LOCATION_FZONE,nil,LOCATION_FZONE)
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_FZONE)
	e3:HOPT()
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end

--E1
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_ZEROST) and not c:IsType(TYPE_TOKEN)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.atkfilter,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,g,#g,1-tp,LOCATION_MZONE,-100)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(-100)
		tc:RegisterEffect(e1)
	end
end

--E2
function s.fusval(e,fc,tp)
	return true, 1
end
function s.fustg(e,c,tp,fc,sub,mg,sg,depth)
	return aux.PLChk(c,tp,LOCATION_GRAVE) and c:IsFusionSetCard(ARCHE_ZEROST) and c:IsMonster() and c:IsAbleToRemove()
end
function s.fusop(g,r)
	return Duel.Remove(g,POS_FACEUP,r)
end

--E3
function s.cfilter(c,_,tp)
	return c:IsPreviousLocation(LOCATION_REMOVED) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and (not c:IsLocation(LOCATION_REMOVED) or not c:IsControler(tp))
		and c:IsPreviousSetCard(ARCHE_ZEROST)
end
function s.filter(c,codes)
	return c:IsSetCard(ARCHE_ZEROST) and not c:IsOriginalCodeRule(table.unpack(codes)) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local codes={}
	for tc in aux.Next(eg) do
		local names={tc:GetOriginalCodeRule()}
		for _,name in ipairs(names) do
			table.insert(codes,name)
		end
	end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,codes)
	end
	e:SetLabel(table.unpack(codes))
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local codes={e:GetLabel()}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,codes)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end