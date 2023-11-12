--[[
Crystarion Sanctum of Purity
Sanctum della Purezza Cristarione
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]


local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	
	--[[When this card is activated: You can send 1 "Crystarion" Ritual Monster from your Deck to your GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If your opponent Summons a monster(s) (except during the Damage Step): You can decrease the Energy of your Engaged "Crystarion" Drive Monster by 1,
	and if you do, that Summoned monster(s) loses ATK/DEF equal to the Energy of your Engaged "Crystarion" Drive Monster x 200.]]
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS},s.simfilter,id,LOCATION_FZONE,nil,LOCATION_FZONE,nil,id+100)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetCustomCategory(CATEGORY_UPDATE_ENERGY)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+s.progressive_id)
	e2:SetRange(LOCATION_FZONE)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.atktg,s.atkop)
	c:RegisterEffect(e2)
	--[[During your End Phase: You can target "Crystarion" Quick-Play Spells in your GY, up to the number of Level 9 "Crystarion" monsters you control; Set them.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE|PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:HOPT()
	e3:SetFunctions(aux.TurnPlayerCond(0),nil,s.settg,s.setop)
	c:RegisterEffect(e3)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgfilter(c)
	return c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_CRYSTARION) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and not Duel.PlayerHasFlagEffect(tp,id) and Duel.SelectYesNo(tp,STRING_ASK_SEND_TO_GY) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end

--E2
function s.simfilter(c,_,tp)
	return c:IsSummonPlayer(1-tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	local g=eg:Filter(Card.IsFaceup,nil)
	if chk==0 then return en and en:IsMonster(TYPE_DRIVE) and en:IsSetCard(ARCHE_CRYSTARION) and en:IsCanUpdateEnergy(-1,tp,REASON_EFFECT,e) and #g>0 end
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		g=g:SelectSubGroup(tp,aux.SimultaneousEventGroupCheck,false,1,#g,id+100,g)
	end
	Duel.HintSelection(g)
	Duel.SetTargetCard(g)
	Duel.SetCustomOperationInfo(0,CATEGORY_UPDATE_ENERGY,en,1,INFOFLAG_DECREASE,1)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,g,#g,0,0,-(en:GetEnergy()-1)*200)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local en=Duel.GetEngagedCard(tp)
	if en and en:IsMonster(TYPE_DRIVE) and en:IsSetCard(ARCHE_CRYSTARION) and en:IsCanUpdateEnergy(-1,tp,REASON_EFFECT,e) then
		local c=e:GetHandler()
		local mod,diff=en:UpdateEnergy(-1,tp,REASON_EFFECT,true,c,e)
		if diff~=0 and not en:IsImmuneToEffect(mod) then
			en=Duel.GetEngagedCard(tp)
			if en and en:IsMonster(TYPE_DRIVE) and en:IsSetCard(ARCHE_CRYSTARION) then
				local val=-en:GetEnergy()*200
				local g=Duel.GetTargetCards():Filter(Card.IsFaceup,nil)
				for tc in aux.Next(g) do
					tc:UpdateATKDEF(val,val,true,c)
				end
			end
		end
	end
end

--E3
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_CRYSTARION) and c:IsLevel(9)
end
function s.setfilter(c)
	return c:IsSpell(TYPE_QUICKPLAY) and c:IsSetCard(ARCHE_CRYSTARION) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,math.min(ct,#g),nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if #tg==0 or ft<#tg then return end
	Duel.SSet(tp,tg)
end