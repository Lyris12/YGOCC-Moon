--Trappitech Quarrycrane Train
--Trappolanigliotech Treno Gruscavatrice
--Scripted by: XGlitchy30

xpcall(function() require("expansions/script/glitchylib_core") end,function() require("script/glitchylib_core") end)

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,3)
	--[[You can also use Set "Trappit" Traps in your Spell & Trap Zones as material for this card's Link Summon.]]
	local ex=Effect.CreateEffect(c)
	ex:SetType(EFFECT_TYPE_FIELD)
	ex:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
	ex:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	ex:SetRange(LOCATION_EXTRA)
	ex:SetTargetRange(LOCATION_SZONE,0)
	ex:SetTarget(s.mattg)
	ex:SetValue(s.matval)
	c:RegisterEffect(ex)
	--[[Gains 1000 ATK for each Normal Summoned/Set monster that was used as material for its Link Summon.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(0)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_SINGLE)
	e1x:SetCode(EFFECT_MATERIAL_CHECK)
	e1x:SetLabelObject(e1)
	e1x:SetValue(s.matcheck)
	c:RegisterEffect(e1x)
	--[[If this card is Link Summoned, or a Normal Trap is activated (in which case, except during the Damage Step): You can add 1 Beast monster from your Deck to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:HOPT()
	e2:SetCondition(aux.LinkSummonedCond)
	e2:SetTarget(s.sctg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:Desc(1)
	e2x:SetCategory(CATEGORIES_SEARCH)
	e2x:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2x:SetProperty(EFFECT_FLAG_DELAY)
	e2x:SetCode(EVENT_CHAIN_SOLVED)
	e2x:SetRange(LOCATION_MZONE)
	e2x:SHOPT()
	e2x:SetCondition(s.sccon)
	e2x:SetTarget(s.sctg)
	e2x:SetOperation(s.scop)
	c:RegisterEffect(e2x)
	--[[During your turn (Quick Effect): You can excavate 3 cards from the top of your Deck, Set all excavated "Trappit" cards to your field,
	also send the rest to the GY, then you can apply 1 of these effects.
	● Immediately after this effect resolves, Normal Summon/Set 1 monster.
	● Flip Summon 1 monster.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_DECKDES|CATEGORY_TOGRAVE|CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetHintTiming(0,RELEVANT_TIMINGS)
	e3:SetCondition(aux.TurnPlayerCond(0))
	e3:SetTarget(s.exctg)
	e3:SetOperation(s.excop)
	c:RegisterEffect(e3)
	if not aux.AddFlipSummonTypeCheck then
		aux.AddFlipSummonTypeCheck=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		ge1:SetOperation(s.regcon)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	for tc in aux.Next(eg) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_ADD_SUMMON_TYPE_KOISHI)
		e1:SetValue(SUMMON_TYPE_FLIP)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~(RESET_TEMP_REMOVE|RESET_TURN_SET|RESET_LEAVE))
		tc:RegisterEffect(e1,true)
	end
end

--EX
function s.matfilter(c)
	if c:IsInBackrow() then
		return c:IsFacedown() and c:IsLinkSetCard(ARCHE_TRAPPIT) and c:IsLinkType(TYPE_TRAP)
	else
		return c:IsLinkRace(RACE_BEAST|RACE_MACHINE)
	end
	return false
end
function s.mattg(e,c)
	return c:IsFacedown() and c:IsSetCard(ARCHE_TRAPPIT) and c:IsTrap()
end
function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	return true,true
end

--E1
function s.value(e,c)
	local ct=e:GetLabel()
	if not ct or ct<0 then ct=0 end
	return ct*1200
end
--E1X
function s.schkfilter(c)
	return c:IsSummonType(SUMMON_TYPE_NORMAL) or c:IsSummonType(SUMMON_TYPE_FLIP)
end
function s.matcheck(e,c)
	local mat=c:GetMaterial()
	local ct = type(mat)~="nil" and mat:FilterCount(s.schkfilter,nil) or 0
	e:GetLabelObject():SetLabel(ct)
end

--FILTERS E2
function s.filter(c)
	return c:IsMonster() and c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
--E2
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--E2X 
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and not re:IsActiveType(TYPE_CONTINUOUS|TYPE_COUNTER) 
end

--FILTERS E3
function s.setfilter(c,e,tp)
	return c:IsSetCard(ARCHE_TRAPPIT) and c:IsCanBeSet(e,tp)
end
function s.sumfilter(c,tp)
	return c:IsSummonableOrSettable() or c:IsCanBeFlipSummoned(tp,true)
end
function s.notfield(c)
	return c:IsST() and not c:IsType(TYPE_FIELD)
end
--E3
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not Duel.IsPlayerCanDiscardDeck(tp,3) or Duel.GetDeckCount(tp)<3 then return false end
		local g=Duel.GetDecktopGroup(tp,3)
		return g:FilterCount(Card.IsCanBeSet,nil,e,tp,true,true)>0
	end
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerCanDiscardDeck(tp,3) then
		Duel.ConfirmDecktop(tp,3)
		local g=Duel.GetDecktopGroup(tp,3)
		if #g>0 then
			Duel.DisableShuffleCheck()
			local sg=g:Filter(s.setfilter,nil,e,tp)
			if #sg>0 then
				local mmz,stz=Duel.GetMZoneCount(tp),Duel.GetLocationCount(tp,LOCATION_SZONE)
				local setg=Group.CreateGroup()
				while #sg>0 do
					if mmz<=0 then
						local mg=sg:Filter(Card.IsMonster,nil)
						sg:Sub(mg)
					end
					if stz<=0 then
						local mg=sg:Filter(s.notfield,nil)
						sg:Sub(mg)
					end
					if #sg>0 then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
						local sg2=sg:FilterSelect(tp,s.setfilter,1,1,nil,e,tp)
						local tc=sg2:GetFirst()
						if tc:IsType(TYPE_FIELD) then
							local fg=sg:Filter(Card.IsType,tc,TYPE_FIELD)
							sg:Sub(fg)
						elseif tc:IsST() then
							stz=stz-1
						elseif tc:IsMonster() then
							mmz=mmz-1
						end
						setg:AddCard(tc)
						sg:RemoveCard(tc)
					end
				end
				if #setg>0 then
					Duel.Set(tp,setg)
					g:Sub(setg)
				end
			end
			Duel.SendtoGrave(g,REASON_EFFECT|REASON_EXCAVATE)
		end
	end
	local sg=Duel.Group(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil,tp)
	Debug.Message(#sg)
	if #sg>0 and e:GetHandler():AskPlayer(tp,3) then
		local sg2=sg:Select(tp,1,1,nil)
		if #sg2>0 then
			local tc=sg2:GetFirst()
			Duel.BreakEffect()
			if tc:IsOnField() and tc:IsFacedown() then
				Duel.FlipSummon(tp,tc)
			else
				Duel.SummonOrSet(tp,tc)
			end
		end
	end
end