--MMS - Liberty Lane, the Magnificent Miraculous Saviour
--MMS - Liberty Lane, la Magnifica Miracolosa Salvatrice
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddFusionProcMix(c,false,true,s.matfilter(ATTRIBUTE_EARTH),s.matfilter(ATTRIBUTE_LIGHT),s.matfilter(ATTRIBUTE_DARK),nil)
	c:EnableReviveLimit()
	--Must be either Fusion Summoned, or Special Summoned by its own effect...
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	--...or Special Summoned (from your Extra Deck) by Tributing 3 Level 7 or higher "MMS -" Fusion Monsters you control.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.sprcon)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	--Negate the effects of all LIGHT and DARK monsters your opponent controls.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.negtg)
	c:RegisterEffect(e2)
	--[[If this card destroys an opponent's monster by battle: You can send 1 Fusion Monster from your Extra Deck to the GY; your opponent banishes 1 card from their Extra Deck, face-down,
	OR if they have no cards in their Extra Deck, you win the Duel instead.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetFunctions(aux.bdocon,s.cost,s.target,s.operation)
	c:RegisterEffect(e3)
	--If this card is banished, or in your GY: You can banish 1 other "MMS -" Fusion Monster from your GY; Special Summon this card.
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GB)
	e4:SetFunctions(nil,aux.BanishCost(s.rmfilter,LOCATION_GRAVE,0,1,1,true),s.hsptg,s.hspop)
	c:RegisterEffect(e4)
end
function s.matfilter(attr)
	return	function(c,fc,sub,mg,sg)
				return c:IsFusionType(TYPE_FUSION) and c:IsFusionAttribute(attr) and c:IsLevelAbove(7)
			end
end

--E1
function s.hspfilter(c,tp,sc)
	return c:IsMonster(TYPE_FUSION) and c:IsSetCard(ARCHE_MMS) and c:IsLevelAbove(7)
		and c:IsControler(tp) and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
function s.gcheck(g,tp,sc)
	return Duel.GetLocationCountFromEx(tp,tp,g,sc)>0 and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
function s.sprcon(e,c)
	if c==nil then return true end
	local g=Duel.GetReleaseGroup(tp):Filter(s.hspfilter,c,tp,c)
	return #g>2 and g:CheckSubGroup(s.gcheck,3,3,tp,c)
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetReleaseGroup(tp):Filter(s.hspfilter,c,tp,c)
	Duel.HintMessage(tp,HINTMSG_RELEASE)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3,tp,c)
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_COST)
end

--E2
function s.negtg(e,c)
	return c:IsAttribute(ATTRIBUTES_CHAOS) and (c:IsType(TYPE_EFFECT) or c:IsOriginalType(TYPE_EFFECT))
end

--E3
function s.cfilter(c)
	return c:IsMonster(TYPE_FUSION) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil,1-tp,POS_FACEDOWN) or Duel.GetExtraDeckCount(1-tp)==0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetExtraDeckCount(1-tp)>0 then
		local g=Duel.Select(HINTMSG_REMOVE,false,1-tp,Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,1,nil,1-tp,POS_FACEDOWN)
		if #g>0 then
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT,1-tp)
		end
	else
		Duel.Win(tp,WIN_REASON_CUSTOM)
	end
end

--E4
function s.rmfilter(c)
	return c:IsMonster(TYPE_FUSION) and c:IsSetCard(ARCHE_MMS)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end