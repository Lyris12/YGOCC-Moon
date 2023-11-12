--Transient Soul of Profane Light
local s,id=GetID()
function s.initial_effect(c)
	--fusion Summon
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	--mill
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.milltg)
	e1:SetOperation(s.millop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.millcon)
	c:RegisterEffect(e2)
	--recur
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:HOPT()
	e3:SetCondition(s.recon)
	e3:SetTarget(s.retg)
	e3:SetOperation(s.reop)
	c:RegisterEffect(e3)
end
--material filters
function s.matfilter1(c)
	return c:GetLevel()>0 and c:IsLevelAbove(5) and c:IsRace(RACE_ZOMBIE)
end
function s.matfilter2(c)
	return c:GetLevel()>0 and c:IsLevelBelow(4) and c:IsRace(RACE_ZOMBIE)
end
--e1/e2
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end 
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsControler(tp)
end
function s.millcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.millfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsControler(tp)
end
function s.milltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(s.millfilter,tp,LOCATION_MZONE,0,nil)>0
		and Duel.GetDecktopGroup(1-tp,1):FilterCount(Card.IsAbleToGrave,nil)>0 end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_DECK)
end
function s.millop(e,tp,eg,ep,ev,re,r,rp)
	local ct1=Duel.GetMatchingGroupCount(s.millfilter,tp,LOCATION_MZONE,0,nil)
	local ct2=Duel.GetDecktopGroup(1-tp,ct1):FilterCount(Card.IsAbleToGrave,nil)
	if ct1>0 and ct2>0 then
		local num={}
		local i=1
		while i<=ct1 and i<=ct2 do
			num[i]=i
			i=i+1
		end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local ct=Duel.AnnounceNumber(tp,table.unpack(num))
		local g=Duel.GetDecktopGroup(1-tp,ct)
		Duel.DisableShuffleCheck()
		Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
	end
end
--e3
function s.refilter(c)
	return c:IsRace(RACE_ZOMBIE) and not c:IsType(TYPE_TOKEN)
end
function s.recon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.refilter,1,nil)
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) end
	if chk==0 then return Duel.IsExistingTarget(aux.FilterBoolFunction(Card.IsFaceup,TRUE),tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
	local g=Duel.SelectTarget(tp,aux.FilterBoolFunction(Card.IsFaceup,TRUE),tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end