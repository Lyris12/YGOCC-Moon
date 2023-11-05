--created by Jake, coded by XGlitchy30; edited by _
--A Blader's Resting Place
local s,id=GetID()
s.original_category={}
function s.initial_effect(c)
	c:Activate()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WARRIOR))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e1x:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e1x)
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:OPT()
	e2:SetLabel(0)
	e2:SetCost(aux.LabelCost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	s.original_category[e2]=e2:GetCategory()
	c:DestroyedTrigger(false,4,CATEGORY_DRAW,EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL,nil,aux.ByCardEffect(1),nil,aux.DrawTarget(),aux.DrawOperation())
end
s.dawn_blader_monster_in_text = true
function s.cfilter(c,f,exc)
	if not f(c) or (exc and c:IsCode(id)) then return false end
	if c:IsMonster() then
		return c:IsSetCard(0x613)
	elseif c:IsST() then
		return c.dawn_blader_monster_in_text~=nil and c.dawn_blader_monster_in_text==true
	end
	return false
end
function s.scfilter(c)
	return c:IsMonster() and c:IsSetCard(0x613) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(0x613) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ogcat = type(s.original_category[e])~="nil" and s.original_category[e] or 0
	e:SetCategory(ogcat)
	local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,Card.IsDiscardable) and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,2,nil,Card.IsDiscardable) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,Card.IsAbleToDeck,true) and Duel.IsPlayerCanDraw(tp,1)
	local b3=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,3,nil,Card.IsDiscardable) and Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return b1 or b2 or b3
	end
	e:SetLabel(0)
	local opt=aux.Option(id,tp,1,b1,b2,b3)
	Duel.DiscardHand(tp,s.cfilter,opt+1,opt+1,REASON_COST+REASON_DISCARD,nil,Card.IsDiscardable)
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCategory(ogcat+CATEGORY_SEARCH+CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif opt==1 then
		e:SetCategory(ogcat+CATEGORY_TODECK+CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif opt==2 then
		e:SetCategory(ogcat+CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local sel=Duel.GetTargetParam()
	if sel==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.Search(g,tp)
		end
	elseif sel==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.cfilter),tp,LOCATION_GRAVE,0,1,3,nil,Card.IsAbleToDeck,true)
		if #g>0 then
			Duel.HintSelection(g)
			if Duel.ShuffleIntoDeck(g,tp)>0 then
				Duel.BreakEffect()
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	elseif sel==2 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
