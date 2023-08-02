--Trappit Heavylifter
--Trappolaniglio Pesomassimo
--Scripted by: XGlitchy30

xpcall(function() require("expansions/script/glitchylib_core") end,function() require("script/glitchylib_core") end)

local s,id=GetID()
function s.initial_effect(c)
	--[[If this card, or another monster(s) (in which case, except during the Damage Step), is Normal or Flip Summoned:
	You can Special Summon 1 Level 1 or 4 Beast monster from your Deck, in face-down Defense Position, then, if you control another "Trappit" card, you can Flip Summon 1 monster.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e1x=e1:FlipSummonEventClone(c)
	--[[You can reveal 1 "Trappit" monster, or 1 Normal Trap, in your hand; immediately after this effect resolves, apply 1 of these effects.
	● Normal Summon 1 monster, and if you do, change 1 Normal Summoned/Set monster you control to face-down Defense Position.
	● Your opponent Normal Summons 1 monster, and if they do, you can change 1 Special Summoned monster they control to face-down Defense Position.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SUMMON|CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCost(s.nscost)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop(0))
	c:RegisterEffect(e2)
	if not aux.TrappitNormalSummonCheck then
		aux.TrappitNormalSummonCheck={false,false}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.regop)
		ge1:SetOwnerPlayer(0)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetOperation(s.regop)
		ge2:SetOwnerPlayer(1)
		Duel.RegisterEffect(ge2,1)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	aux.TrappitNormalSummonCheck[tp] = Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,true,nil)	
end

--Filters E1
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsLevel(1,4) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
--Text sections E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_TRAPPIT),tp,LOCATION_ONFIELD,0,1,c)
		and Duel.IsExistingMatchingCard(Card.IsCanBeFlipSummoned,tp,LOCATION_MZONE,0,1,nil,tp,true) and c:AskPlayer(tp,2) then
			local fg=Duel.Select(HINTMSG_FLIPSUMMON,false,tp,Card.IsCanBeFlipSummoned,tp,LOCATION_MZONE,0,1,1,nil,tp,true)
			if #fg>0 then
				Duel.HintSelection(fg)
				Duel.BreakEffect()
				Duel.FlipSummon(tp,fg:GetFirst())
			end
		end
	end
end

--Filters E2
function s.costfilter(c)
	return (c:IsMonster() and c:IsSetCard(ARCHE_TRAPPIT) or c:IsNormalTrap()) and not c:IsPublic()
end
function s.posfilter(c,sumtype)
	return c:IsSummonType(sumtype) and c:IsCanTurnSetGlitchy()
end
--Text sections E2
function s.nscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,true,nil) then return true end
		local hg=Duel.GetHand(1-tp)
		return (#hg>0 and hg:IsExists(aux.NOT(Card.IsPublic),1,nil) and Duel.IsPlayerCanSummon(1-tp)) or aux.TrappitNormalSummonCheck[1-tp]==true
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,PLAYER_ALL,LOCATION_HAND|LOCATION_MZONE)
end
function s.nsop(mode)
	if mode==0 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local hg=Duel.GetHand(1-tp)
					local b1 = Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,true,nil)
					local b2 = (#hg>0 and hg:IsExists(aux.NOT(Card.IsPublic),1,nil) and Duel.IsPlayerCanSummon(1-tp)) or aux.TrappitNormalSummonCheck[1-tp]==true
					local opt = aux.Option(tp,id,3,b1,b2)
					if opt==0 then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
						local g=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,true,nil)
						local tc=g:GetFirst()
						if tc then
							local e1=Effect.CreateEffect(e:GetHandler())
							e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
							e1:SetCode(EVENT_SUMMON_SUCCESS)
							e1:SetLabelObject(tc)
							e1:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
								s.nsop(1)(e,tp,eg,ep,ev,re,r,rp,_e)
								_e:Reset()
							end
							)
							e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
							tc:RegisterEffect(e1,true)
							Duel.Summon(tp,tc,true,nil)
						end
					
					elseif opt==1 then
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
						e1:SetCode(EVENT_CHAIN_SOLVED)
						e1:SetLabelObject(e)
						e1:SetOperation(s.nsop(2))
						e1:SetOwnerPlayer(1-tp)
						Duel.RegisterEffect(e1,1-tp)
					end
				end
				
	elseif mode==1 then
		return	function(e,tp,eg,ep,ev,re,r,rp,ce)
					local g=Duel.Select(HINTMSG_POSITION,false,tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil,SUMMON_TYPE_NORMAL)
					if #g>0 then
						Duel.HintSelection(g)
						Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
					end
				end
				
	elseif mode==2 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					if re~=e:GetLabelObject() then return end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
					local g=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,true,nil)
					local tc=g:GetFirst()
					if tc then
						local e1=Effect.CreateEffect(e:GetOwner())
						e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
						e1:SetCode(EVENT_SUMMON_SUCCESS)
						e1:SetLabelObject(tc)
						e1:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
							s.nsop(3)(e,1-tp,eg,ep,ev,re,r,rp,_e)
							_e:Reset()
						end
						)
						e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
						tc:RegisterEffect(e1,true)
						Duel.Summon(tp,tc,true,nil)
					end
					e:Reset()
				end
				
	elseif mode==3 then
		return	function(e,tp,eg,ep,ev,re,r,rp,ce)
					local g=Duel.Group(s.posfilter,tp,0,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
					if #g>0 and e:GetHandler():AskPlayer(tp,5) then
						Duel.HintMessage(tp,HINTMSG_POSITION)
						local sg=g:Select(tp,1,1,nil)
						if #sg>0 then
							Duel.HintSelection(sg)
							Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
						end
					end
				end
	end
end	